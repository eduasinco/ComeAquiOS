//
//  ImportImagesViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol ImportImagesProtocol {
    func images(images: [UIImage])
}

class ImportImagesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageButton1: URLImageButtonView!
    @IBOutlet weak var width1: NSLayoutConstraint!
    @IBOutlet weak var imageButton2: URLImageButtonView!
    @IBOutlet weak var width2: NSLayoutConstraint!
    @IBOutlet weak var imageButton3: URLImageButtonView!
    @IBOutlet weak var width3: NSLayoutConstraint!
    @IBOutlet weak var spinner1: UIActivityIndicatorView!
    @IBOutlet weak var spinner2: UIActivityIndicatorView!
    @IBOutlet weak var spinner3: UIActivityIndicatorView!
    
    var buttonPressed: URLImageButtonView?
    var buttons: [URLImageButtonView]!
    var spinners: [UIActivityIndicatorView]!
    var widths: [NSLayoutConstraint]!
    var images: [FoodPostImageObject?] = [nil, nil, nil]
    
    var foodPostId: Int!
    var delegate: ImportImagesProtocol?
    var selectedImage: FoodPostImageObject?
    
    func setImages(images: [FoodPostImageObject]){
        for (i, image) in images.enumerated() {
            buttons[i].loadImageUsingUrlString(urlString: image.food_photo!)
            self.images[i] = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = [imageButton1, imageButton2, imageButton3]
        spinners = [spinner1, spinner2, spinner3]
        widths = [width1, width2, width3]
        for i in 0..<buttons.count{
            buttons[i].textFieldBorderStyle()
            widths[i].constant = buttons[i].frame.height
            buttons[i].tag = i
            buttons[i].imageView?.contentMode = .scaleAspectFill
            buttons[i].addTarget(self, action:#selector(tappedButton), for: .touchUpInside)
            spinners[i].visibility = .gone
        }
    }
    @objc func tappedButton(_ sender: UIButton?, index: Int) {
        buttonPressed = sender as? URLImageButtonView
        if let image = images[Int(buttonPressed!.tag)] {
            selectedImage = image
            performSegue(withIdentifier: "ImageLookerSegue", sender: image.food_photo)
        } else {
            performSegue(withIdentifier: "GalleryCameraSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GalleryCameraSegue" {
            let gcVC = segue.destination as? GaleryCameraPopUpViewController
            gcVC?.delegate = self
        } else if segue.identifier == "ImageLookerSegue" {
            let ilVC = segue.destination as? ImageLookerViewController
            ilVC?.delegate = self
            ilVC?.deleteButtonVisible = true
            ilVC?.image = sender as? String
        }
    }
}

extension ImportImagesViewController: GaleryCameraPopUpProtocol, ImageLookerProtocol{
    func deleteImage(_ urlImage: String?) {
        images[Int(buttonPressed!.tag)] = nil
        Server.delete("/image/\(self.selectedImage!.id!)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            guard let _ = data else {return}
            DispatchQueue.main.async {
                self.buttonPressed?.setImage(UIImage(systemName: "camera"), for: .normal)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    func image(_ image: UIImage) {
        self.spinners[buttonPressed!.tag].visibility = .visible
        Server.uploadPictures(method: .post, urlString: SERVER + "/food_images/\(self.foodPostId!)/", withName: "image", pictures: image, finish: whenFinished)
    }
}

extension ImportImagesViewController {
    func whenFinished(data: Data?) {
        guard let data = data else {return}
        do {
            self.spinners[self.buttonPressed!.tag].visibility = .gone
            let foodPostImage = try JSONDecoder().decode(FoodPostImageObject.self, from: data)
            images[Int(buttonPressed!.tag)] = foodPostImage
            DispatchQueue.main.async {
                self.buttonPressed?.loadImageUsingUrlString(urlString: foodPostImage.food_photo!)
            }
        } catch _ {
            self.view.showToast(message: "Some error ocurred")
        }
    }
}
