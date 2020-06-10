//
//  GaleryCameraPopUpViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import AVFoundation


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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkCamera()
    }
    
    @IBAction func galleryPress(_ sender: Any) {
        importImage(true)
    }
    @IBAction func cameraPress(_ sender: Any) {
        importImage(false)
    }
    
    func importImage(_ gallery: Bool){
        if gallery {
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = .photoLibrary
            image.allowsEditing = false
            self.present(image, animated: true){}
        }
        
        if !gallery, UIImagePickerController.isSourceTypeAvailable(.camera) {
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = .camera
            image.allowsEditing = false
            self.present(image, animated: true){}
        } else {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: true, completion: nil)
            delegate?.image(image)
        } else {
            // error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized: break // Do your stuff here i.e. allowScanning()
        case .denied: alertToEncourageCameraAccessInitially()
        case .notDetermined: alertPromptToAllowCameraAccessViaSetting()
        default: alertToEncourageCameraAccessInitially()
        }
    }

    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access is needed in order for you to upload a photo",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!)
        }))
        present(alert, animated: true, completion: nil)
    }

    func alertPromptToAllowCameraAccessViaSetting() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access is needed in order for you to upload a photo",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { alert in
            if AVCaptureDevice.devices(for: .video).count > 0 {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async() {
                        self.checkCamera()
                        
                    }
                }
            }}
        )
        present(alert, animated: true, completion: nil)
    }
}
