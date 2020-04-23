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

    @IBOutlet weak var imageButton1: UIButton!
    @IBOutlet weak var width1: NSLayoutConstraint!
    @IBOutlet weak var imageButton2: UIButton!
    @IBOutlet weak var width2: NSLayoutConstraint!
    @IBOutlet weak var imageButton3: UIButton!
    @IBOutlet weak var width3: NSLayoutConstraint!
    
    var buttonPressed: UIButton?
    
    var buttons: [UIButton]!
    var widths: [NSLayoutConstraint]!
    var images: [UIImage?] = [nil, nil, nil]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = [imageButton1, imageButton2, imageButton3]
        widths = [width1, width2, width3]
        for i in 0..<buttons.count{
            buttons[i].textFieldBorderStyle()
            widths[i].constant = buttons[i].frame.height
            buttons[i].tag = i
            buttons[i].imageView?.contentMode = .scaleAspectFill
            buttons[i].addTarget(self, action:#selector(tappedButton), for: .touchUpInside)
        }
    }
    @objc func tappedButton(_ sender: UIButton?, index: Int) {
        buttonPressed = sender!
        if let image = images[Int(buttonPressed!.tag)] {
            performSegue(withIdentifier: "ImageLookerSegue", sender: image)
        } else {
            performSegue(withIdentifier: "GalleryCameraSegue", sender: nil)
        }
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
            buttonPressed?.setImage(image, for: .normal)
            images[Int(buttonPressed!.tag)] = image
        } else {
            // error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GalleryCameraSegue" {
            let gcVC = segue.destination as? GaleryCameraPopUpViewController
            gcVC?.delegate = self
        } else if segue.identifier == "ImageLookerSegue" {
            let ilVC = segue.destination as? ImageLookerViewController
            ilVC?.delegate = self
            ilVC?.deleteButtonVisible = true
            ilVC?.image = sender as? UIImage
        }
    }
}

extension ImportImagesViewController: GaleryCameraPopUpProtocol, ImageLookerProtocol{
    func deleteImage() {
        images[Int(buttonPressed!.tag)] = nil
        buttonPressed?.setImage(UIImage(systemName: "camera"), for: .normal)
    }
    
    func from(_ gallery: Bool) {
        importImage(gallery)
    }
}
