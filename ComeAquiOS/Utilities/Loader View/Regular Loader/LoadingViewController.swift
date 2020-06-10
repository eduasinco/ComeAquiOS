//
//  LoadingViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
    }
}
