//
//  Images.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 12/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ReloadingImage: UIImageView {
    
    let reloadButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let spinner: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var reloadAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        commonInit()
    }
    
    private func commonInit() {
        self.addSubview(reloadButton)
        reloadButton.isHidden = true
        reloadButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        reloadButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        reloadButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        reloadButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        reloadButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        reloadButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle.fill"), for: .normal)
        
        self.addSubview(spinner)
        spinner.isHidden = true
        spinner.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        spinner.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        spinner.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    @objc func buttonAction(sender: UIButton!) {
        reloadAction?()
    }
}

class URLImageView: ReloadingImage {
    var urlString: String?
    var defaultImage: UIImage?

    override func layoutSubviews() {
        super.layoutSubviews()
        self.defaultImage = self.image
    }
    public func loadImageUsingUrlString(urlString: String?) {
        reloadAction = {
            self.loadImageUsingUrlString(urlString: urlString)
        }
        spinner.isHidden = false
        spinner.startAnimating()
        guard let urlString = urlString else {
            spinner.isHidden = true
            spinner.stopAnimating()
            self.image = defaultImage
            return
        }
        self.urlString = urlString
        let url = NSURL(string: urlString)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, respones, error) in
            DispatchQueue.main.async{
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
            }
            if error != nil {
                DispatchQueue.main.async{
                    self.reloadButton.isHidden = false
                }
                print(error ?? "Errooooor")
                return
            }
            DispatchQueue.main.async{
                let image = UIImage(data: data!)
                if image != nil {
                    self.image = image
                }
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
    }
    
    public func loadImageUsingUrlString(urlString: String?, secondImage: UIImage? = nil) {
        guard let urlString = urlString, !urlString.contains("no-image"), !urlString.isEmpty else {
            self.image = secondImage
            return
        }

        let serverUrlString = urlString
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
            DispatchQueue.main.async{
                let imageToCache = UIImage(data: data)
                if self.imageUrlString == serverUrlString {
                    self.image = imageToCache
                }
                guard imageToCache != nil else {return}
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
        let url = NSURL(string: urlString)
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
    var deleteAvailable =  false
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
        self.isUserInteractionEnabled = true
    }
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        presentFunction?()
    }
    override func loadImageUsingUrlString(urlString: String?) {
        super.loadImageUsingUrlString(urlString: urlString)
        self.presentFunction = {
            let storyBoard: UIStoryboard = UIStoryboard(name: "ImageLookerStoryboard", bundle: nil)
            let imageVC = storyBoard.instantiateViewController(withIdentifier: "ImageLooker") as! ImageLookerViewController
            imageVC.image = urlString
            imageVC.deleteButtonVisible = self.deleteAvailable
            if self.parentViewController is ImageLookerProtocol {
                imageVC.delegate = self.parentViewController as? ImageLookerProtocol
            }
            self.parentViewController?.present(imageVC, animated: true, completion: nil)
        }
    }
}
