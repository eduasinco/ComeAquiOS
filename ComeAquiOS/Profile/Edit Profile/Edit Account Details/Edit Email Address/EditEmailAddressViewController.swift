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
        Server.get("/send_code_to_email/\(emailText.text!)/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                self.alert.dismiss(animated: false, completion: nil)
            }
            guard let data = data else {
                return
            }
            do {
                USER = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.saveButton.visibility = .gone
                    self.verificationCodeStack.visibility = .visible
                }
            } catch let _ {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                    DispatchQueue.main.async {
                        self.emailText.validationText = json["message"] as? String
                    }
                }catch let _ {}
            }
        })
    }
    func sendCode(){
        present(alert, animated: false, completion: nil)
        Server.post("/is_code_valid/",
                     json:
            [
                "code": verificationCodeText.text,
                "new_email": emailAddress!,
            ],
                     finish: {(data: Data?, response: URLResponse?) -> Void in
                        DispatchQueue.main.async {
                            self.alert.dismiss(animated: false, completion: nil)
                        }
                        guard let data = data else {
                            return
                        }
                        do {
                            USER = try JSONDecoder().decode(User.self, from: data)
                            DispatchQueue.main.async {
                                self.emailSavedText.visibility = .visible
                                self.saveButton.visibility = .gone
                                self.verificationCodeStack.visibility = .gone
                            }
                        } catch let _ {
                            do {
                                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                                DispatchQueue.main.async {
                                    self.verificationCodeText.validationText = json["message"] as? String
                                }
                            }catch let _ {}
                        }
        })
    }
}
