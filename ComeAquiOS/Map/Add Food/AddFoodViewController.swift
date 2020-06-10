//
//  AddFoodViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class AddFoodViewController: KUIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var plateNameText: ValidatedTextField!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var dinnersText: ValidatedTextField!
    @IBOutlet weak var priceText: CurrencyTextField!
    @IBOutlet weak var descriptionText: ValidatedTextView!
    @IBOutlet weak var wordCountText: UILabel!
    @IBOutlet weak var holderBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: LoadingButton!
    
    var placeAutocompleteVC: PlaceAutocompleteViewController?
    var datePickerVC: DateTimePickerViewController?
    var typesVC: TypesViewController?
    var importImageVC: ImportImagesViewController?
    
    var location: PlaceG?
    var startDate: String?
    var endDate: String?
    var price: Int?
    var types: String?
    var descriptionString: String?
    
    var foodPost: FoodPostObject?
    var foodPostId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = holderBottomConstraint
        priceText.addTarget(self, action: #selector(myTextFieldBegin), for: .editingChanged)
        plateNameText.textFieldBorderStyle()
        locationContainer.textFieldBorderStyle()
        dinnersText.textFieldBorderStyle()
        priceText.textFieldBorderStyle()
        descriptionText.textFieldBorderStyle()
        descriptionText.delegate = self
        
        if self.foodPostId != nil {
            self.importImageVC?.foodPostId = self.foodPostId
            getFoodPost()
        } else {
            postFood()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.foodPostId == nil {
            trueDeletePost()
        }
    }
    
    func setFoodPost() {
        if (self.foodPost?.plate_name) != nil {
            plateNameText.text = self.foodPost?.plate_name
        }
        if let placeId = self.foodPost?.place_id{
            placeAutocompleteVC?.getPlaceDetailFromGoogle(placeId: placeId)
        } else if (location != nil) {
            placeAutocompleteVC?.getPlaceDetailFromGoogle(placeId: location!.result!.place_id!)
        }
        if let dinners = self.foodPost?.max_dinners {
            dinnersText.text = "\(dinners)"
        }
        if let startTime = self.foodPost?.start_time, let endTime =  self.foodPost?.end_time{
            datePickerVC?.setDateTime(startDateString: startTime, endDateString: endTime)
        }
        if let price = self.foodPost?.price {
            self.price = price
            priceText.text = "$ " + price.format()
        }
        setTypeVC()
        if let description = self.foodPost?.description {
            self.descriptionText.text = description
        }
        if let images = self.foodPost?.images {
            importImageVC?.setImages(images: images)
        }
    }
    
    func validateData() -> Bool{
        var valid = true
        if plateNameText.text == nil || plateNameText.text!.isEmpty {
            plateNameText.validationText = "Meal should not be empty"
            valid = false
        }
        if location == nil {
            placeAutocompleteVC?.textField.validationText = "You should set a location for your meal"
            valid = false
        }
        if dinnersText.text == nil || dinnersText.text!.isEmpty{
            dinnersText.validationText = "You should set a dinner quantity"
            valid = false
        }
        if startDate == nil || endDate == nil{
            datePickerVC?.dateText.validationText = "Chose a date for your meal"
            valid = false
        }
        if price == nil {
            priceText.validationText = "Pleace insert a price for your meal"
            valid = false
        }
        if descriptionText.text == nil || descriptionText!.text!.isEmpty  {
            descriptionText.validationText = "Meal description should not be empty"
            valid = false
        }
        return valid
    }
    
    
    @IBAction func submit(_ sender: Any) {
        if validateData() {
            pathFoodPost(visible: true)
        }
    }
    @IBAction func optionsPressed(_ sender: Any) {
        performSegue(withIdentifier: "OptionsSegue", sender: nil)
        
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
        if segue.identifier == "DatePickerSegue" {
            datePickerVC = segue.destination as? DateTimePickerViewController
            datePickerVC?.delegate = self
            datePickerVC?.view.textFieldBorderStyle()
        } else if segue.identifier == "PlaceAutocompleteSegue" {
            placeAutocompleteVC = segue.destination as? PlaceAutocompleteViewController
            placeAutocompleteVC?.delegate = self
            placeAutocompleteVC?.closeVisible = false
        } else if segue.identifier == "ImageImporterSegue" {
            importImageVC = segue.destination as? ImportImagesViewController
            importImageVC?.delegate = self
            importImageVC?.foodPostId = self.foodPost?.id
        } else if segue.identifier == "OptionsSegue" {
            let optionsVC = segue.destination as? OptionsPopUpViewController
            var options: [String] = []
            options.append("Save")
            options.append("Delete");
            optionsVC?.options = options
            optionsVC?.delegate = self
        }
    }
    
    func setTypeVC() {
        let storyboard = UIStoryboard(name: "TypesStoryboard", bundle: nil)
        typesVC = storyboard.instantiateViewController(identifier: "TypesView") as? TypesViewController
        if let typesVC = self.typesVC {
            typesVC.initialTypesString = self.foodPost?.food_type ?? "0000000"
            typesVC.delegate = self
            addChild(typesVC)
            stackView.insertArrangedSubview(typesVC.view, at: 5)
            typesVC.didMove(toParent: self)
            let h = typesVC.view.heightAnchor.constraint(equalToConstant: 20)
            h.priority = UILayoutPriority(rawValue: 1000)
            h.isActive = true
        }
    }
}

extension AddFoodViewController {
    func getFoodPost(){
        
        Server.get("/foods/\(foodPostId!)/"){ data, response, error in
            DispatchQueue.main.async {
                
            }
            guard let data = data else {
                return
            }
            do {
                self.foodPost = try JSONDecoder().decode(FoodPostObject.self, from: data)
                DispatchQueue.main.async {
                    self.setFoodPost()
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        }
    }
    func trueDeletePost(){
        guard let foodPost = self.foodPost else { return }
        Server.delete("/true_food_delete/\(foodPost.id!)/"){ data, response, error in
            guard let _ = data else {return}
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    func pathFoodPost(visible: Bool){
        submitButton.showLoading()
        Server.patch("/foods/\(self.foodPost!.id!)/",
            json:
            ["plate_name":  plateNameText.text,
             "formatted_address":  self.location?.result?.formatted_address,
             "place_id":  location?.result?.place_id,
             "lat":  location?.result?.geometry?.location?.lat,
             "lng":  location?.result?.geometry?.location?.lng,
             "max_dinners":  dinnersText.text!.isEmpty ? nil : dinnersText.text,
             "dinners_left":  dinnersText.text!.isEmpty ? nil : dinnersText.text,
             "start_time": startDate,
             "end_time":  endDate,
             "price":  price,
             "food_type":  types,
             "description":  descriptionText.text,
             "visible": visible ? "true" : "false"]) { data, response, error in
                DispatchQueue.main.async {
                    self.submitButton.hideLoading()
                }
                if let _ = error {
                    DispatchQueue.main.async {
                        self.viewHolder.showToast(message: "No internet connection")
                    }
                }
                guard let data = data else {return}
                do {
                    self.foodPost = try JSONDecoder().decode(FoodPostObject.self, from: data)
                    self.foodPostId = self.foodPost?.id
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch _ {
                    self.view.showToast(message: "Some error ocurred")
                }
        }
    }
    func postFood(){
        submitButton.showLoading()
        Server.post("/foods/",
                    json:
            ["plate_name":  nil,
             "formatted_address":  nil,
             "place_id":  nil,
             "street_n":  nil,
             "route":  nil,
             "administrative_area_level_2":  nil,
             "administrative_area_level_1":  nil,
             "country":  nil,
             "postal_code":  nil,
             "lat":  nil,
             "lng":  nil,
             "max_dinners":  nil,
             "dinners_left":  nil,
             "start_time":  nil,
             "end_time":  nil,
             "time_zone":  nil,
             "price":  nil,
             "food_type":  nil,
             "description":  nil,
             "visible": "false"]) { data, response, error in
                DispatchQueue.main.async {
                    self.submitButton.hideLoading()
                }
                if let _ = error {
                    self.view.showToast(message: "No internet connection")
                }
                guard let data = data else {
                    return
                }
                do {
                    self.foodPost = try JSONDecoder().decode(FoodPostObject.self, from: data)
                    DispatchQueue.main.async {
                        self.importImageVC?.foodPostId = self.foodPost!.id!
                        self.setFoodPost()
                    }
                } catch _ {
                    self.view.showToast(message: "Some error ocurred")
                }
        }
    }
}

extension AddFoodViewController: TypesProtocol, AutocompleteProtocol, DatePickerProtocol, ImportImagesProtocol, OptionsPopUpProtocol {
    func optionPressed(_ title: String) {
        switch title {
        case "Save":
            pathFoodPost(visible: false)
            break
        case "Delete":
            trueDeletePost()
            break
        default:
            break
        }
    }
    
    func images(images: [UIImage]) {
        
    }
    
    func close() {
        
    }
    func placeSelected(place: PlaceG?) {
        self.location = place
    }
    
    func datesPicked(startDate: String, endDate: String) {
        self.startDate = startDate
        self.endDate = endDate
    }
    func invalidStartDate() {
        
    }
    
    func typeChanged(types: String) {
        self.types = types
    }
}


