//
//  ChangePasswordViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 11/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ChangePasswordViewController: LoadViewController {

    @IBOutlet weak var setPasswordStack: UIStackView!
    @IBOutlet weak var oldPasswordText: ValidatedTextField!
    @IBOutlet weak var newPasswordText: ValidatedTextField!
    
    @IBOutlet weak var passwordSettedSuccessfullyStack: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordSettedSuccessfullyStack.visibility = .gone
    }
    
    @IBAction func savePassword(_ sender: Any) {
        if newPasswordText.text!.isValidPassword() {
            passwordChange()
        } else {
            newPasswordText.validationText = "A digit must occur at least once \n" +
            "A lower case letter must occur at least once \n" +
            "An upper case letter must occur at least once \n" +
            "A special character (!?@#$%^&+=) must occur at least once \n" +
            "No whitespace allowed in the entire string \n" +
            "It needs to be at least 8 characters long"
        }
    }
    @IBAction func goToLogin(_ sender: Any) {
        USER = nil
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ChangePasswordViewController {
    func passwordChange(){
        
        Server.patch("/password_change/",
                     json:
            [
                "old_password": oldPasswordText.text,
                "new_password": newPasswordText.text,
            ],
                     finish: {(data: Data?, response: URLResponse?) -> Void in
                        DispatchQueue.main.async {
                            
                        }
                        guard let data = data else {
                            return
                        }
                        do {
                            guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                            guard let oldPasswordA = json["old_password"] as? [Any] else {
                                DispatchQueue.main.async {
                                    self.setPasswordStack.visibility = .gone
                                    self.passwordSettedSuccessfullyStack.visibility = .visible
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                self.oldPasswordText.validationText = oldPasswordA[0] as? String
                            }
                        } catch _ {}
        })
    }
}
