//
//  AllViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol FilterDelegate {
    func sort(sortType: Int)
    func price(price: Int)
    func mealTime(startTime: String, endTime: String)
    func distance(distance: Int)
    func dietary(type: String)
}

class AllViewController: UIViewController {

    var delegate: FilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
