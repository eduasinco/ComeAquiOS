//
//  ImageLookerViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
protocol  ImageLookerProtocol{
    func deleteImage(_ urlImage: String?)
}
class ImageLookerViewController: UIViewController {

    @IBOutlet weak var imageView: URLImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var deleteButtonVisible = false
    var image: String?
    var isFullUrl: Bool = false
    
    var delegate: ImageLookerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.visibility = deleteButtonVisible ? .visible : .gone
        imageView.loadImageUsingUrlString(urlString: image, isFullUrl: isFullUrl)
    }
    @IBAction func deletePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.deleteImage(image)
    }
}
