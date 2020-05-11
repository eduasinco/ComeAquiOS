//
//  GaleryCameraPopUpViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
protocol GaleryCameraPopUpProtocol {
    func image(_ image: UIImage)
}

class GaleryCameraPopUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var camerButton: UIButton!
    @IBOutlet weak var popUp: UIView!
    
    var delegate: GaleryCameraPopUpProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUp.roundCorners(radius: 8)
    }
    
    @IBAction func galleryPress(_ sender: Any) {
        importImage(true)
    }
    @IBAction func cameraPress(_ sender: Any) {
        importImage(false)
    }
    
    func importImage(_ gallery: Bool){
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = gallery ? .photoLibrary : .camera
        image.allowsEditing = false
        self.present(image, animated: true){}
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            delegate?.image(image)
        } else {
            // error
        }
        self.dismiss(animated: true, completion: nil)
    }
}
