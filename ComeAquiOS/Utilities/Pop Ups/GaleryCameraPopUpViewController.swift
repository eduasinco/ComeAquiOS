//
//  GaleryCameraPopUpViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
protocol GaleryCameraPopUpProtocol {
    func from(_ gallery: Bool)
}

class GaleryCameraPopUpViewController: UIViewController {
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var camerButton: UIButton!
    @IBOutlet weak var popUp: UIView!
    
    var delegate: GaleryCameraPopUpProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUp.roundCorners(radius: 8)
    }
    
    @IBAction func galleryPress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        delegate?.from(true)
    }
    @IBAction func cameraPress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        delegate?.from(false)
    }
}
