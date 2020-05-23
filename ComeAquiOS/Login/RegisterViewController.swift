//
//  RegisterViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class RegisterViewController: KUIViewController {

    @IBOutlet weak var username: ValidatedTextField!
    @IBOutlet weak var firstName: ValidatedTextField!
    @IBOutlet weak var lastName: ValidatedTextField!
    @IBOutlet weak var email: ValidatedTextField!
    @IBOutlet weak var password: ValidatedTextField!
    @IBOutlet weak var bottomHolderConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = bottomHolderConstraint
    }
    
    func isValid() -> Bool{
        var valid = true
        
        if username.text!.isEmpty || !username.text!.isValidUsername() {
            username.validationText = "Please insert a valid username"
            valid = false
        }
        if firstName.text!.isEmpty {
            firstName.validationText = "Please insert a valid name"
            valid = false
        }
        if lastName.text!.isEmpty {
            lastName.validationText = "Please insert a valid surname"
            valid = false
        }
        if email.text!.isEmpty || !email.text!.isValidEmail() {
            email.validationText = "Please insert a valid email"
            valid = false
        }
        if password.text!.isEmpty || !password.text!.isValidPassword() {
            password.validationText =
                "It must have at least 8 characters \n" +
                "A digit must occur at least once \n" +
                "A lower case letter must occur at least once \n" +
                "An upper case letter must occur at least once \n" +
                "A special character (!?@#$%^&+=) must occur at least once \n" +
            "No whitespace allowed in the entire string \n"
            valid = false
        }
        return valid
    }
    @IBAction func registerPress(_ sender: Any) {
        if isValid() {
            register()
        }
    }
}

extension RegisterViewController {
    private struct ErrorResponseObject: Decodable {
        var username: [String]?
        var email: [String]?
    }
    func register(){
        
        let endpointUrl = URL(string: SERVER + "/register/")! // whatever is your url
        var request = URLRequest(url: endpointUrl)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let data = try JSONSerialization.data(withJSONObject:
                ["username":  username.text,
                 "first_name":  firstName.text,
                 "last_name":  lastName.text,
                 "email":  email.text,
                 "password":  password.text], options: [])
            request.httpMethod = "POST"
            request.httpBody = data
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
                DispatchQueue.main.async {
                    
                }
                guard let data = data else {return}
                do {
                    USER = try JSONDecoder().decode(User.self, from: data)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "PresentationSegue", sender: nil)
                    }
                } catch _ {
                    do {
                        let errorObject = try JSONDecoder().decode(ErrorResponseObject.self, from: data)
                        DispatchQueue.main.async {
                            if let usernameError = errorObject.username, usernameError.count > 0 {
                                self.username.validationText = usernameError[0]
                            }
                            if let emailError = errorObject.email, emailError.count > 0 {
                                self.email.validationText = emailError[0]
                            }
                        }
                    } catch _ {}
                }
            })
            task.resume()
        }catch{
            //
        }
    }
    
}
