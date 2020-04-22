//
//  AddFoodViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class AddFoodViewController: UIViewController {
    var googleMapsLocation: GoogleMapsLocation?
    
    @IBOutlet weak var plateNameText: UITextField!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var dinnersText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var wordCountText: UILabel!
    
    var plateName: String?
    var location: PlaceG?
    var dinners: Int?
    var startDate: Date?
    var endDate: Date?
    var price: Int?
    var types: String?
    var descriptionString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


