//
//  Images.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 12/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit


class URLImageView: UIImageView {
    var urlString: String?
    var defaultImage: UIImage?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.defaultImage = self.image
    }
    public func loadImageUsingUrlString(urlString: String?, isFullUrl: Bool = false) {
        guard let urlString = urlString else {
            self.image = defaultImage
            return
        }
        self.urlString = urlString
        let url = NSURL(string: (isFullUrl ? "" : SERVER) + urlString)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, respones, error) in
            if error != nil {
                print(error ?? "Errooooor")
                return
            }
            DispatchQueue.main.async{
                let image = UIImage(data: data!)
                self.image = image
            }
        }).resume()
    }
}

private let imageCache = NSCache<NSString, UIImage>()
class CellImageView: UIImageView {
    var imageUrlString: String?
    var defaultImage: UIImage?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.defaultImage = self.image
    }
    
    public func loadImageUsingUrlString(urlString: String?) {
        guard let urlString = urlString else {
            self.image = defaultImage
            return
        }
        let serverUrlString = SERVER + urlString
        imageUrlString = serverUrlString
        let url = NSURL(string: serverUrlString)
        
        image = nil
        if let imageFromCache = imageCache.object(forKey: NSString(string: serverUrlString)) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, respones, error) in
            if error != nil {
                print(error ?? "Errooooor")
                return
            }
            guard let data = data else {return}
            guard !serverUrlString.contains("no-image") else {return}
            DispatchQueue.main.async{
                let imageToCache = UIImage(data: data)
                if self.imageUrlString == serverUrlString {
                    self.image = imageToCache
                }
                imageCache.setObject(imageToCache!, forKey:  NSString(string: serverUrlString))
            }
        }).resume()
    }
}

class URLImageButtonView: UIButton {
    var urlString: String?
    var defaultImage: UIImage?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.defaultImage = self.imageView?.image
    }
    public func loadImageUsingUrlString(urlString: String?) {
        guard let urlString = urlString else {
            self.setImage(defaultImage, for: .normal)
            return
        }
        self.urlString = urlString
        let url = NSURL(string: SERVER + urlString)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, respones, error) in
            if error != nil {
                print(error ?? "Errooooor")
                return
            }
            DispatchQueue.main.async{
                let image = UIImage(data: data!)
                self.setImage(image, for: .normal)
            }
        }).resume()
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
class ImageToOpen: URLImageView {
    var presentFunction: (() -> Void)?
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
        self.isUserInteractionEnabled = true
    }
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        presentFunction?()
    }
    override func loadImageUsingUrlString(urlString: String?, isFullUrl: Bool = false) {
        super.loadImageUsingUrlString(urlString: urlString, isFullUrl: isFullUrl)
        self.presentFunction = {
            let storyBoard: UIStoryboard = UIStoryboard(name: "ImageLookerStoryboard", bundle: nil)
            let imageVC = storyBoard.instantiateViewController(withIdentifier: "ImageLooker") as! ImageLookerViewController
            imageVC.image = urlString
            imageVC.isFullUrl = isFullUrl
            if self.parentViewController is ImageLookerProtocol {
                imageVC.delegate = self.parentViewController as? ImageLookerProtocol
            }
            self.parentViewController?.present(imageVC, animated: true, completion: nil)
        }
    }
}
