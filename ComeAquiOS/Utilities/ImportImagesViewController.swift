//
//  ImportImagesViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ImportImagesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageButton1: UIButton!
    @IBOutlet weak var width1: NSLayoutConstraint!
    @IBOutlet weak var imageButton2: UIButton!
    @IBOutlet weak var width2: NSLayoutConstraint!
    @IBOutlet weak var imageButton3: UIButton!
    @IBOutlet weak var width3: NSLayoutConstraint!
    
    var buttonPressed: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        width1.constant = imageButton1.frame.height
        width2.constant = imageButton2.frame.height
        width3.constant = imageButton3.frame.height
        
        imageButton1.textFieldBorderStyle()
        imageButton2.textFieldBorderStyle()
        imageButton3.textFieldBorderStyle()
    }
    @IBAction func button1Pressed(_ sender: Any) {
        buttonPressed = imageButton1
        importImage()
    }
    @IBAction func button2Pressed(_ sender: Any) {
        buttonPressed = imageButton2
        importImage()
    }
    @IBAction func button3Pressed(_ sender: Any) {
        buttonPressed = imageButton3
        importImage()
    }
    
    func importImage(){
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .camera
        image.allowsEditing = false
        self.present(image, animated: true){
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            buttonPressed?.setImage(image, for: .normal)
        } else {
            // error
        }
        self.dismiss(animated: true, completion: nil)
    }
}
