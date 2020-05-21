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
    var image: String?
    
    var delegate: ImageLookerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.visibility = delegate == nil ? .gone : .visible
        deleteButton.visibility = deleteButtonVisible ? .visible : .gone
        imageView.loadImageUsingUrlString(urlString: image!)
    }
    @IBAction func deletePressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        delegate?.deleteImage()
    }
}
