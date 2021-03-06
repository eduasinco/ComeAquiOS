//
//  EditAccountDetailsViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 10/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
private class ResponseObject: Decodable {
    var error_message: String?
    var data: [PaymentMethodObject]?
}

class EditAccountDetailsViewController: KUIViewController {
    
    @IBOutlet weak var firstName: ValidatedTextField!
    @IBOutlet weak var lastName: ValidatedTextField!
    @IBOutlet weak var phoneNumber: ValidatedTextField!
    @IBOutlet weak var emailAddress: UIView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var password: UIView!
    @IBOutlet weak var creditCard: UILabel!
    
    
    @IBOutlet weak var bcfkb: NSLayoutConstraint!
    var user: User?
    var paymentMethod: PaymentMethodObject?
    var isBackgroundImageChanging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = bcfkb
    }
    override func viewWillAppear(_ animated: Bool) {
        getUser()
    }
    func setView(){
        guard let user = self.user else {return}
        firstName.placeholder = user.first_name
        lastName.placeholder = user.last_name
        phoneNumber.placeholder = user.phone_number
        emailText.placeholder = user.email
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.changeEmail(_:)))
        emailAddress.addGestureRecognizer(gesture)
        let pgesture = UITapGestureRecognizer(target: self, action: #selector(self.changePassword(_:)))
        password.addGestureRecognizer(pgesture)

        guard let paymentMethod = self.paymentMethod else {return}
        creditCard.text = paymentMethod.last4
    }
    @objc func changeEmail(_ gestureRecognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "EditEmailAddressSegue", sender: nil)
    }
    @objc func changePassword(_ gestureRecognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "ChangePasswordSegue", sender: nil)
    }
    
    func isValid() -> Bool{
        var valid = true
        if firstName.text!.isEmpty {
            firstName.validationText = "Insert a valid Name"
            valid = false
        }
        if lastName.text!.isEmpty {
            lastName.validationText = "Insert a valid Last Name"
            valid = false
        }
        if phoneNumber.text!.isEmpty {
            phoneNumber.validationText = "Insert a valid Phone "
            valid = false
        }
        return valid
    }
    
    @IBAction func editProfile(_ sender: Any) {
        if true || isValid(){
            patchAccount()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GalleryCameraSegue" {
            _ = segue.destination as? GaleryCameraPopUpViewController
        } else if segue.identifier == "EditEmailAddressSegue" {
            _ = segue.destination as? EditEmailAddressViewController
        } else if segue.identifier == "ChangePasswordSegue" {
            _ = segue.destination as? ChangePasswordViewController
        }
    }
}

extension EditAccountDetailsViewController {
    func getUser(){
        presentLoader()
        Server.get("/profile_detail/\(USER.id!)/"){ data, response, error in
            self.closeLoader()
            guard let data = data else {
                return
            }
            do {
                self.user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.getChosenCard()
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        }
    }
    func getChosenCard(){
        presentLoader()
        Server.get("/my_chosen_card/"){ data, response, error in
            self.closeLoader()
            guard let data = data else {
                return
            }
            do {
                let responseO = try JSONDecoder().decode(ResponseObject.self, from: data)
                if responseO.error_message == nil {
                    if let data = responseO.data, data.count > 0 {
                        self.paymentMethod = data[0]
                    }
                    DispatchQueue.main.async {
                        self.setView()
                    }
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        }
    }
    
    func patchAccount(){
        presentTransparentLoader()
        Server.patch("/edit_profile/",
                     json: ["first_name": firstName.text,
                            "last_name": lastName.text,
                            "phone_number": phoneNumber.text]) { data, response, error in
                            if let _ = error {
                                self.view.showToast(message: "No internet connection")
                            }
                        self.closeTransparentLoader()
                        guard data != nil else {return}
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
        }
    }
}

