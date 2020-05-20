//
//  PresentationViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class PresentationViewController: UIViewController {

    @IBOutlet weak var message: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        message.text! += USER.full_name!
    }
}
