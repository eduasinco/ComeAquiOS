//
//  ImageLookerViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
protocol  ImageLookerProtocol{
    func deleteImage()
}
class ImageLookerViewController: UIViewController {

    @IBOutlet weak var imageView: URLImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var deleteButtonVisible = false
    var image: UIImage?
    
    var delegate: ImageLookerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteButton.visibility = deleteButtonVisible ? .visible : .gone
        imageView.image = image
    }
    @IBAction func deletePressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        delegate?.deleteImage()
    }
}
