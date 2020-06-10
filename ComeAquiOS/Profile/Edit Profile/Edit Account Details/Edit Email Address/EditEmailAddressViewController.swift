//
//  EditEmailAddressViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 11/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class EditEmailAddressViewController: LoadViewController {

    @IBOutlet weak var emailText: ValidatedTextField!
    @IBOutlet weak var emailSavedText: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var verificationCodeStack: UIStackView!
    @IBOutlet weak var verificationCodeText: ValidatedTextField!
    
    var emailAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verificationCodeStack.visibility = .gone
        emailSavedText.visibility = .gone
        emailText.placeholder = USER.email
    }
    
    @IBAction func saveEmail(_ sender: Any) {
        sendEmail()
    }
    @IBAction func sendVerificationCode(_ sender: Any) {
        if !verificationCodeText.text!.isEmpty {
            sendCode()
        } else {
            verificationCodeText.validationText = "Please insert a valid code"
        }
    }
    @IBAction func codeDidntArrive(_ sender: Any) {
        sendEmail()
    }
    
    func sendEmail() {
        if emailText.text!.isValidEmail() {
            emailAddress = emailText.text
            sendEmailOnServer()
        } else {
            emailText.validationText = "Please insert a valid email"
        }
    }
    
}

extension EditEmailAddressViewController {
    func sendEmailOnServer(){
        Server.get("/send_code_to_email/\(emailText.text!)/"){ data, response, error in
            DispatchQueue.main.async {
                
            }
            guard let data = data else {
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                if let message = json["message"] as? String {
                    DispatchQueue.main.async {
                        self.emailText.validationText = message
                    }
                    return
                } else {
                    USER = try JSONDecoder().decode(User.self, from: data)
                    DispatchQueue.main.async {
                        self.saveButton.visibility = .gone
                        self.verificationCodeStack.visibility = .visible
                    }
                }
            } catch _ {}
            
        }
    }
    func sendCode(){
        
        Server.post("/is_code_valid/",
                     json:
            [
                "code": verificationCodeText.text,
                "new_email": emailAddress!,
            ]) { data, response, error in
            if let _ = error {
                self.view.showToast(message: "No internet connection")
            }
                        guard let data = data else {return}
                        do {
                            USER = try JSONDecoder().decode(User.self, from: data)
                            DispatchQueue.main.async {
                                self.emailSavedText.visibility = .visible
                                self.saveButton.visibility = .gone
                                self.verificationCodeStack.visibility = .gone
                            }
                        } catch _ {
                            do {
                                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                                DispatchQueue.main.async {
                                    self.verificationCodeText.validationText = json["message"] as? String
                                }
                            }catch _ {}
                        }
        }
    }
}
