//
//  ReloadViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 09/06/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ReloadViewController: UIViewController {

    @IBOutlet weak var reloadButton: UIButton!
    var onReload: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func reloadButtonPressed(_ sender: Any) {
        view.isHidden = true
        onReload?()
    }
}
