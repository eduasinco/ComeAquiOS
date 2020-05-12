//
//  Images.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 12/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit


class URLImageView: UIImageView {
    public func loadImageUsingUrlString(urlString: String, isFullUrl: Bool = false) {
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
    
    public func loadImageUsingUrlString(urlString: String) {
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
    public func loadImageUsingUrlString(urlString: String) {
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
