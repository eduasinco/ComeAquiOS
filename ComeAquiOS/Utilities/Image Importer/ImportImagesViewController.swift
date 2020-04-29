//
//  ImportImagesViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import Alamofire


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
            performSegue(withIdentifier: "ImageLookerSegue", sender: image.food_photo)
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
            postComplexPictures(urlString: SERVER + "/food_images/\(self.foodPostId!)/", pictures: image, finish: whenFinished)
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
            ilVC?.image = sender as? String
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

extension ImportImagesViewController {
    func whenFinished(data: Data) {
        do {
            let foodPostImage = try JSONDecoder().decode(FoodPostImageObject.self, from: data)
            images[Int(buttonPressed!.tag)] = foodPostImage
            DispatchQueue.main.async {
                self.buttonPressed?.loadImageUsingUrlString(urlString: foodPostImage.food_photo!)
            }
        } catch let jsonErr {
            print("json could'nt be parsed \(jsonErr)")
        }
    }
    func postComplexPictures(urlString: String, pictures : UIImage, finish: @escaping ((Data)) -> Void) {
        
        let urll = URL(string: urlString)
        guard let url = urll else { return }
        
        var result:(message:String, list:[[String: Any]],isSuccess:Bool) = (message: "Fail", list:[], isSuccess : false)
        let headers: HTTPHeaders
        headers = ["Content-type": "multipart/form-data",
                   "Content-Disposition" : "form-data",
                   "Authorization" : "Basic \(getBase64LoginString())"
        ]
        
        self.spinners[buttonPressed!.tag].visibility = .visible
        AF.upload(multipartFormData: { (multipartFormData) in
//            for (key, value) in params {
//                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
//            }
            if let imageData = pictures.pngData() {
                multipartFormData.append(imageData, withName: "image", fileName: "IMAGE.png", mimeType: "image/png")
            }
        }, to: url, usingThreshold: UInt64.init(), method: .post, headers: headers).response{ response in
            if((response.data != nil)){
                finish(response.data!)
            } else {
                print("error")
            }
            self.spinners[self.buttonPressed!.tag].visibility = .gone
        }
    }
}
