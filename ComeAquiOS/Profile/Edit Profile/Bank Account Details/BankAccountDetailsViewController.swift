//
//  BankAccountDetailsViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 11/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class BankAccountDetailsViewController: KUIViewController {

    @IBOutlet weak var accountMessage: UILabel!
    @IBOutlet weak var firstName: ValidatedTextField!
    @IBOutlet weak var lastName: ValidatedTextField!
    @IBOutlet weak var dateOfBirth: ValidatedTextField!
    @IBOutlet weak var ssn: ValidatedTextField!
    @IBOutlet weak var idValidationText: UILabel!
    @IBOutlet weak var frontIdButton: UIButton!
    @IBOutlet weak var backIdButton: UIButton!
    @IBOutlet weak var phoneNumber: ValidatedTextField!
    @IBOutlet weak var addressLine1: ValidatedTextField!
    @IBOutlet weak var addressLine2: ValidatedTextField!
    @IBOutlet weak var city: ValidatedTextField!
    @IBOutlet weak var state: ValidatedTextField!
    @IBOutlet weak var zip: ValidatedTextField!
    @IBOutlet weak var country: ValidatedTextField!
    @IBOutlet weak var routingNumber: ValidatedTextField!
    @IBOutlet weak var accountNumber: ValidatedTextField!
    
    @IBOutlet weak var bcfkb: NSLayoutConstraint!
    var stripeAccountInfo: StripeAccountInfoObject?
    var birthDate: Date?
    var day: Int?
    var month: Int?
    var year: Int?
    
    var isFrontId = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idValidationText.visibility = .gone
        accountMessage.visibility = .gone
        self.bottomConstraintForKeyboard = bcfkb
        
        let datePickerForDateText = UIDatePicker()
        datePickerForDateText.datePickerMode = .date
        datePickerForDateText.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        dateOfBirth.inputView = datePickerForDateText
        
        getBankAccountInfo()
    }
    
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        birthDate = datePicker.date
        day = birthDate!.get(.day)
        month = birthDate!.get(.day)
        year = birthDate!.get(.day)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateOfBirth.text = dateFormatter.string(from: birthDate!)

    }
    
    func setView(){
        guard let stripeAccountInfo = self.stripeAccountInfo else {return}
        firstName.placeholder = stripeAccountInfo.individual?.first_name
        lastName.placeholder = stripeAccountInfo.individual?.last_name
        if let year = stripeAccountInfo.individual?.dob?.year, let month = self.stripeAccountInfo?.individual?.dob?.month, let day = self.stripeAccountInfo?.individual?.dob?.day {
            dateOfBirth.placeholder = "\(day)/\(month)/\(year)"
        }
        if let id_number = stripeAccountInfo.individual?.id_number {
            ssn.placeholder = "\(id_number)"
        }
        if stripeAccountInfo.individual?.verification?.document?.front != nil {
            frontIdButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        if stripeAccountInfo.individual?.verification?.document?.back != nil {
            backIdButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        phoneNumber.placeholder = stripeAccountInfo.individual?.phone
        addressLine1.placeholder = stripeAccountInfo.individual?.address?.line1
        addressLine2.placeholder = stripeAccountInfo.individual?.address?.line2
        city.placeholder = stripeAccountInfo.individual?.address?.city
        state.placeholder = stripeAccountInfo.individual?.address?.state
        zip.placeholder = stripeAccountInfo.individual?.address?.postal_code
        country.placeholder = stripeAccountInfo.individual?.address?.country
        
        if let data = self.stripeAccountInfo!.external_accounts!.data, data.count > 0 {
            routingNumber.placeholder = data[0].routing_number
            accountNumber.placeholder = data[0].last4
        } else {
            routingNumber.placeholderColor(UIColor.red)
            accountNumber.placeholderColor(UIColor.red)
        }
        
        if (stripeAccountInfo.payouts_enabled!){
            accountMessage.text = "Account verified"
        } else if (stripeAccountInfo.requirements!.currently_due!.count == 0){
            accountMessage.text = "Pending review"
        } else {
            accountMessage.text = "Account incomplete"
        }
        accountMessage.visibility = .visible
        
        guard let currentlyDue = self.stripeAccountInfo!.requirements!.currently_due else {return}
        for due in currentlyDue {
            switch due {
                case "individual.address.line1":
                    addressLine1.placeholderColor(UIColor.red)
                    break;
                case "individual.address.line2":
                    addressLine2.placeholderColor(UIColor.red)
                    break;
                case "individual.address.country":
                    country.placeholderColor(UIColor.red)
                    break;
                case "individual.address.city":
                    city.placeholderColor(UIColor.red)
                    break;
                case "individual.address.postal_code":
                    zip.placeholderColor(UIColor.red)
                    break;
                case "individual.address.state":
                    state.placeholderColor(UIColor.red)
                    break;
                case "individual.dob.day":
                    dateOfBirth.placeholderColor(UIColor.red)
                    break;
                case "individual.dob.month":
                    dateOfBirth.placeholderColor(UIColor.red)
                    break;
                case "individual.dob.year":
                    dateOfBirth.placeholderColor(UIColor.red)
                    break;
                case "individual.first_name":
                    firstName.placeholderColor(UIColor.red)
                    break;
                case "individual.last_name":
                    lastName.placeholderColor(UIColor.red)
                    break;
                case "individual.phone":
                    phoneNumber.placeholderColor(UIColor.red)
                    break;
                case "ndividual.ssn_last_4":
                    ssn.placeholderColor(UIColor.red)
                    break;
                case "individual.id_number":
                    ssn.placeholderColor(UIColor.red)
                    break;
            default:
                break
            }
        }
    }
    
    func validateFrom() -> Bool{
        var isValid = true
        if (!ssn.text!.isEmpty && ssn.text!.count < 9){
            ssn.validationText = "SSN number should be at least 9 digits"
            isValid = false
        }
        if (!routingNumber.text!.isEmpty && routingNumber.text!.count < 9){
            routingNumber.validationText = "Routing number should be at least 9 digits"
            isValid = false
        }
        return isValid
    }
    
    @IBAction func frontId(_ sender: Any) {
        isFrontId = true
        performSegue(withIdentifier: "GalleryCameraSegue", sender: nil)
    }
    @IBAction func backId(_ sender: Any) {
        isFrontId = false
        performSegue(withIdentifier: "GalleryCameraSegue", sender: nil)
    }
    @IBAction func saveForm(_ sender: Any) {
        if validateFrom(){
            save()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GalleryCameraSegue" {
            let gcVC = segue.destination as? GaleryCameraPopUpViewController
            gcVC?.delegate = self
        }
    }
}

extension BankAccountDetailsViewController: GaleryCameraPopUpProtocol {
    func image(_ image: UIImage) {
        if isFrontId {
            present(alert, animated: false, completion: nil)
            Server.uploadPictures(method: .patch, urlString: SERVER + "/upload_stripe_document/", withName: "front", pictures: image, finish: {(data: Data?) -> Void in
                DispatchQueue.main.async {
                    self.alert.dismiss(animated: false, completion: nil)
                }
                guard let data = data else {return}
                do {
                    self.stripeAccountInfo = try JSONDecoder().decode(StripeAccountInfoObject.self, from: data)
                    if self.stripeAccountInfo?.error_message == nil {
                        DispatchQueue.main.async {
                            self.backIdButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
                        }
                    } else {
                        
                    }
                } catch {}
            })
        } else {
            present(alert, animated: false, completion: nil)
            Server.uploadPictures(method: .patch, urlString: SERVER + "/upload_stripe_document/", withName: "back", pictures: image, finish: {(data: Data?) -> Void in
                DispatchQueue.main.async {
                    self.alert.dismiss(animated: false, completion: nil)
                }
                guard let data = data else {return}
                do {
                    self.stripeAccountInfo = try JSONDecoder().decode(StripeAccountInfoObject.self, from: data)
                    if self.stripeAccountInfo?.error_message == nil {
                        DispatchQueue.main.async {
                            self.backIdButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
                        }
                    } else {
                        
                    }
                } catch {}
            })
        }
    }
}
extension BankAccountDetailsViewController {
    func getBankAccountInfo(){
        present(alert, animated: false, completion: nil)
        Server.get("/stripe_account/", finish: {(data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                self.alert.dismiss(animated: false, completion: nil)
            }
            guard let data = data else {return}
            do {
                self.stripeAccountInfo = try JSONDecoder().decode(StripeAccountInfoObject.self, from: data)
                if self.stripeAccountInfo?.error_message == nil {
                    DispatchQueue.main.async {
                        self.setView()
                    }
                } else {
                    
                }
            } catch {}
        })
    }
    
    func save(){
        present(alert, animated: false, completion: nil)
        Server.post("/stripe_account/",
                    json:
            [
                "first_name": firstName.text,
                "last_name": lastName.text,
                "day": day,
                "month": month,
                "year": year,
                "ssn_last_4": ssn.text,
                "id_number": ssn.text,
                "phone": phoneNumber.text,
                "line1": addressLine1.text,
                "line2": addressLine2.text,
                "city": city.text,
                "state": state.text,
                "postal_code": zip.text,
                "country": country.text,
                "routing_number": routingNumber.text,
                "account_number": accountNumber.text
            ],
                    finish: {(data: Data?, response: URLResponse?) -> Void in
                        DispatchQueue.main.async {
                            self.alert.dismiss(animated: false, completion: nil)
                        }
                        guard let data = data else {
                            return
                        }
                        do {
                            self.stripeAccountInfo = try JSONDecoder().decode(StripeAccountInfoObject.self, from: data)
                            if self.stripeAccountInfo?.error_message == nil {
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                    self.dismiss(animated: true, completion: nil)
                                }
                            } else {
                                guard let e_message = self.stripeAccountInfo?.error_message else {return}
                                DispatchQueue.main.async {
                                    if (e_message.contains("individual[first_name]")) {
                                        self.firstName.validationText = "First name is not valid"
                                    }
                                    if (e_message.contains("individual[last_name]")) {
                                        self.lastName.validationText = "Last name is not valid"
                                    }
                                    if (
                                        e_message.contains("individual[dob][year]") ||
                                            e_message.contains("individual[dob][day]") ||
                                            e_message.contains("individual[dob][month]")
                                        ) {
                                        self.dateOfBirth.validationText = "Date of birth is not valid"
                                    }
                                    if (e_message.contains("individual[ssn_last_4]")) {
                                        self.ssn.validationText = "SSN number is not valid"
                                    }
                                    if (e_message.contains("individual[id_number]")) {
                                        self.ssn.validationText = "SSN number is not valid"
                                    }
                                    if (e_message.contains("individual[phone]")) {
                                        self.phoneNumber.validationText = "The phone number is not valid"
                                    }
                                    if (e_message.contains("individual[address][line1]")) {
                                        self.addressLine1.validationText = "Invalid address"
                                    }
                                    if (e_message.contains("individual[address][line2]")) {
                                        self.addressLine2.validationText = "Invalid address"
                                    }
                                    if (e_message.contains("individual[address][city]")) {
                                        self.city.validationText = "Invalid city"
                                    }
                                    if (e_message.contains("individual[address][state]")) {
                                        self.state
                                            .validationText = "Invalid state"
                                    }
                                    if (e_message.contains("individual[address][postal_code]")) {
                                        self.zip.validationText = "Invalid US postal code"
                                    }
                                    if (e_message.contains("individual[address][country]")) {
                                        self.country.validationText =  "The Country is not valid"
                                    }
                                    if (e_message.contains("external_account[routing_number]")) {
                                        self.routingNumber.validationText = "The routing number is not valid"
                                    }
                                    if (e_message.contains("external_account[account_number]")) {
                                        self.accountNumber.validationText =  "The account number is not valid"
                                    }
                                }
                            }
                        } catch let jsonErr {
                            print("json could'nt be parsed \(jsonErr)")
                        }
        })
    }
}