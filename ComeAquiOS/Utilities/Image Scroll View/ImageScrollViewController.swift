//
//  ImageScrollViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 01/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ImageScrollViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var image1: URLImageView!
    @IBOutlet weak var image1Width: NSLayoutConstraint!
    @IBOutlet weak var image2: URLImageView!
    @IBOutlet weak var image3: URLImageView!
    
    var images: [FoodPostImageObject]?
    var foodPostId: Int? {
        didSet {
            getFoodPostImages()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.delegate = self
    }
    
    func setView(){
        guard let images = self.images else {
            imageScrollView.visibility = .gone
            return
        }
        
        let imageArray = [image1, image2, image3]
        imageScrollView.visibility = .visible
        imageScrollView.isHidden = false
        if images.count == 0 {
            imageScrollView.visibility = .gone
        } else if images.count == 1 {
            self.image1.loadImageUsingUrlString(urlString: images[0].food_photo)
            image1Width.constant = imageScrollView.frame.width
            image1.isHidden = false
        } else {
            for (i, image) in images.enumerated(){
                imageArray[i]!.visibility = .visible
                imageArray[i]!.loadImageUsingUrlString(urlString: image.food_photo)
            }
        }
        var i = images.count
        while i < imageArray.count {
            imageArray[i]!.visibility = .gone
            i += 1
        }
    }
}

extension ImageScrollViewController {
    func getFoodPostImages(){
        guard let foodPostId = self.foodPostId else { return }
        Server.get( "/food_images/\(foodPostId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            guard let data = data else {return}
            if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {}
            do {
                self.images = try JSONDecoder().decode([FoodPostImageObject].self, from: data)
                DispatchQueue.main.async {
                    self.setView()
                }
            } catch {}
        })
    }
}
