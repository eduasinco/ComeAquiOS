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
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var creditCard: UILabel!
    
    
    @IBOutlet weak var bcfkb: NSLayoutConstraint!
    var user: User?
    var paymentMethod: PaymentMethodObject?
    var isBackgroundImageChanging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = bcfkb
        getUser()
    }
    func setView(){
        guard let user = self.user else {return}
        firstName.placeholder = user.first_name
        lastName.placeholder = user.last_name
        phoneNumber.placeholder = user.phone_number
        emailAddress.placeholder = user.email

        guard let paymentMethod = self.paymentMethod else {return}
        creditCard.text = paymentMethod.last4
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.changeEmail(_:)))
        emailAddress.addGestureRecognizer(gesture)
        let pgesture = UITapGestureRecognizer(target: self, action: #selector(self.changePassword(_:)))
        password.addGestureRecognizer(pgesture)
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
        if isValid(){
            patchAccount()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GalleryCameraSegue" {
            let gcVC = segue.destination as? GaleryCameraPopUpViewController
        } else if segue.identifier == "EditEmailAddressSegue" {
            let editEAVC = segue.destination as? EditEmailAddressViewController
        } else if segue.identifier == "ChangePasswordSegue" {
            let editEAVC = segue.destination as? ChangePasswordViewController
        }
    }
}

extension EditAccountDetailsViewController {
    func getUser(){
        Server.get("/profile_detail/\(USER.id!)/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                self.alert.dismiss(animated: false, completion: nil)
            }
            guard let data = data else {
                return
            }
            do {
                self.user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.getChosenCard()
                }
            } catch let jsonErr {
                print("json could'nt be parsed \(jsonErr)")
            }
        })
    }
    func getChosenCard(){
        Server.get("/my_chosen_card/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                self.alert.dismiss(animated: false, completion: nil)
            }
            guard let data = data else {
                return
            }
            do {
                let responseO = try JSONDecoder().decode(ResponseObject.self, from: data)
                if responseO.error_message == nil {
                    self.paymentMethod = responseO.data![0]
                    DispatchQueue.main.async {
                        self.setView()
                    }
                }
            } catch let jsonErr {
                print("json could'nt be parsed \(jsonErr)")
            }
        })
    }
    
    func patchAccount(){
        present(alert, animated: false, completion: nil)
        Server.patch("/edit_profile/",
                     json:
            [
                "first_name": firstName.text,
                "last_name": lastName.text,
                "phone_number": phoneNumber.text
            ],
                     finish: {(data: Data?, response: URLResponse?) -> Void in
                        DispatchQueue.main.async {
                            self.alert.dismiss(animated: false, completion: nil)
                        }
                        guard let data = data else {
                            return
                        }
                        do {
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                                self.dismiss(animated: true, completion: nil)
                            }
                        } catch let jsonErr {
                            print("json could'nt be parsed \(jsonErr)")
                        }
        })
    }
}

