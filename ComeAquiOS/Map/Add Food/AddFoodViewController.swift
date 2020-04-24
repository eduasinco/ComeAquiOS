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
    
    @IBOutlet weak var valField: ValidationTextField!
    @IBOutlet weak var plateNameText: ValidationTextField2!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var dinnersText: UITextField!
    @IBOutlet weak var priceText: CurrencyTextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var wordCountText: UILabel!
    @IBOutlet weak var holderBottomConstraint: NSLayoutConstraint!
    
    var placeAutocompleteVC: PlaceAutocompleteViewController?
    var datePickerVC: DateTimePickerViewController?
    var typesVC: TypesViewController?
    var importImageVC: ImportImagesViewController?
    
    var plateName: String?
    var location: PlaceG?
    var dinners: Int?
    var startDate: Date?
    var endDate: Date?
    var price: Int?
    var types: String?
    var descriptionString: String?
    
    var foodPost: FoodPostObject?
    var foodPostId: Int?

    let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = holderBottomConstraint
        priceText.addTarget(self, action: #selector(myTextFieldBegin), for: .editingChanged)
        descriptionText.textFieldBorderStyle()
        locationContainer.textFieldBorderStyle()
        descriptionText.delegate = self
        

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: false, completion: nil)
        
        if self.foodPostId != nil {
            self.importImageVC?.foodPostId = self.foodPostId
            getFoodPost()
        } else {
            postFood()
        }
    }
    func setFoodPost() {
        if (self.foodPost?.plate_name) != nil {
            plateNameText.text = plateName
        }
        if let placeId = self.foodPost?.place_id {
            placeAutocompleteVC?.getPlaceDetailFromGoogle(placeId: placeId)
        }
        if let dinners = self.foodPost?.max_dinners {
            dinnersText.text = "\(dinners)"
        }
        if let startTime = self.foodPost?.start_time, let endTime =  self.foodPost?.end_time{
            datePickerVC?.setDateTime(startDateString: startTime, endDateString: endTime)
        }
        if let types = self.foodPost?.food_type{
            typesVC?.setTypes(typeString: types)
        }
        if let description = self.foodPost?.description {
            self.descriptionText.text = description
        }
        if let images = self.foodPost?.images {
            importImageVC?.setImages(images: images)
        }
    }
    
    func validateData(){
        if (self.foodPost?.plate_name) != nil {
            plateNameText.text = plateName
        }
        if let placeId = self.foodPost?.place_id {
            placeAutocompleteVC?.getPlaceDetailFromGoogle(placeId: placeId)
        }
        if let dinners = self.foodPost?.max_dinners {
            dinnersText.text = "\(dinners)"
        }
        if let startTime = self.foodPost?.start_time, let endTime =  self.foodPost?.end_time{
            datePickerVC?.setDateTime(startDateString: startTime, endDateString: endTime)
        }
        if let types = self.foodPost?.food_type{
            typesVC?.setTypes(typeString: types)
        }
        if let description = self.foodPost?.description {
            self.descriptionText.text = description
        }
        if let images = self.foodPost?.images {
            importImageVC?.setImages(images: images)
        }
    }
    
    override func viewDidLayoutSubviews() {
        //plateNameText.validationLabel.circle()
      }
      

    @IBAction func submit(_ sender: Any) {
        valField.validationLabel.text = "I dont know I dont know I dont know I dont know I dont know I dont know I dont know"
        valField.showValidationText(true)
        plateNameText.validationLabel.text = "I dont "
        plateNameText.showValidationText(true)
        
//        Server.post("/foods/",
//                    json:
//            ["plate_name":  nil,
//             "formatted_address":  nil,
//             "place_id":  nil,
//             "street_n":  nil,
//             "route":  nil,
//             "administrative_area_level_2":  nil,
//             "administrative_area_level_1":  nil,
//             "country":  nil,
//             "postal_code":  nil,
//             "lat":  nil,
//             "lng":  nil,
//             "max_dinners":  nil,
//             "dinners_left":  nil,
//             "start_time":  nil,
//             "end_time":  nil,
//             "time_zone":  nil,
//             "price":  nil,
//             "food_type":  nil,
//             "description":  nil,
//             "visible":  nil],
//                    finish: {(data: Data?) -> Void in
//                        DispatchQueue.main.async {
//                            self.alert.dismiss(animated: false, completion: nil)
//                        }
//                        guard let data = data else {
//                            return
//                        }
//                        do {
//                            self.foodPost = try JSONDecoder().decode(FoodPostObject.self, from: data)
//                            DispatchQueue.main.async {
//                                self.importImageVC?.foodPostId = self.foodPost!.id!
//                            }
//                        } catch let jsonErr {
//                            print("json could'nt be parsed \(jsonErr)")
//                        }
//        }
//        )
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
            typesVC = segue.destination as? TypesViewController
            typesVC?.delegate = self
            typesVC?.toInteract = true
        } else if segue.identifier == "DatePickerSegue" {
            datePickerVC = segue.destination as? DateTimePickerViewController
            datePickerVC?.delegate = self
        } else if segue.identifier == "PlaceAutocompleteSegue" {
            placeAutocompleteVC = segue.destination as? PlaceAutocompleteViewController
            placeAutocompleteVC?.delegate = self
            placeAutocompleteVC?.closeVisible = false
        } else if segue.identifier == "ImageImporterSegue" {
            importImageVC = segue.destination as? ImportImagesViewController
            importImageVC?.delegate = self
            importImageVC?.foodPostId = self.foodPost?.id
        }
    }
}

extension AddFoodViewController {
    func getFoodPost(){
        Server.get("/foods/\(foodPostId!)/", finish: {
            (data: Data?) -> Void in
            DispatchQueue.main.async {
                self.alert.dismiss(animated: false, completion: nil)
            }
            guard let data = data else {
                return
            }
            do {
                self.foodPost = try JSONDecoder().decode(FoodPostObject.self, from: data)
                DispatchQueue.main.async {
                    self.setFoodPost()
                }
            } catch let jsonErr {
                print("json could'nt be parsed \(jsonErr)")
            }
        })
    }
    func postFood(){
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
             "visible":  nil],
                    finish: {(data: Data?) -> Void in
                        DispatchQueue.main.async {
                            self.alert.dismiss(animated: false, completion: nil)
                        }
                        guard let data = data else {
                            return
                        }
                        do {
                            self.foodPost = try JSONDecoder().decode(FoodPostObject.self, from: data)
                            DispatchQueue.main.async {
                                self.importImageVC?.foodPostId = self.foodPost!.id!
                            }
                        } catch let jsonErr {
                            print("json could'nt be parsed \(jsonErr)")
                        }
        }
        )
    }
}

extension AddFoodViewController: TypesProtocol, AutocompleteProtocol, DatePickerProtocol, ImportImagesProtocol {
    func images(images: [UIImage]) {
        
    }
    
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


