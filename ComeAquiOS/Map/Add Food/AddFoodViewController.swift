//
//  AddFoodViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class AddFoodViewController: KUIViewController, UITextFieldDelegate, UITextViewDelegate {
    var googleMapsLocation: GoogleMapsLocation?
    
    @IBOutlet weak var plateNameText: UITextField!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var dinnersText: UITextField!
    @IBOutlet weak var priceText: CurrencyTextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var wordCountText: UILabel!
    @IBOutlet weak var holderBottomConstraint: NSLayoutConstraint!
    
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
        self.bottomConstraintForKeyboard = holderBottomConstraint
        priceText.addTarget(self, action: #selector(myTextFieldBegin), for: .editingChanged)
        descriptionText.textFieldBorderStyle()
        locationContainer.textFieldBorderStyle()
        descriptionText.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        wordCountText.text = "\(numberOfChars)/202"
        return numberOfChars < 202    // 10 Limit Value
    }
    
    @objc func myTextFieldBegin(_ textField: UITextField) {
        price = Int(priceText.enteredNumbers) ?? 0
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
            locationVC?.closeVisible = false
        }
    }
}

extension AddFoodViewController: TypesProtocol, AutocompleteProtocol, DatePickerProtocol {
    
    func close() {
        
    }
    func placeSelected(place: PlaceG?) {
        self.location = place
    }
    
    func datesPicked(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    func invalidStartDate() {
        
    }
    
    func typeChanged(types: String) {
        self.types = types
    }
}


