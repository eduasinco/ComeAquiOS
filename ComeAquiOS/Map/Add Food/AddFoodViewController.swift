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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypesSegue" {
            let typesVC = segue.destination as? TypesViewController
            typesVC?.delegate = self
            typesVC?.toInteract = true
        } else if segue.identifier == "DatePickerSegue" {
            let datePickerVC = segue.destination as? DateTimePickerViewController
            datePickerVC?.delegate = self
        } else if segue.identifier == "PlaceAutocompleteSegue" {
            let locationVC = segue.destination as? PlaceAutocompleteViewController
            locationVC?.delegate = self
        }
    }
}

extension AddFoodViewController: TypesProtocol, AutocompleteProtocol, DatePickerProtocol {
    func close() {
        
    }
    
    func placeSelected(place: PlaceG) {
        self.location = place
    }
    
    func datesPicked(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func typeChanged(types: String) {
        self.types = types
    }
}


