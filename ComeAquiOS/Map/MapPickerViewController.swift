//
//  MapPickerViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class MapPickerViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pan: UIView!
    @IBOutlet weak var handle: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pan.roundCorners(radius: pan.frame.height/2).border(witdth: handle.frame.width)
        label.roundCorners(radius: label.frame.height/2)
        handle.circle()
        // Do any additional setup after loading the view.
    }
}
