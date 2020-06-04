//
//  ForgotPasswordViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 11/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: LoadViewController {
    
    @IBOutlet weak var sendNewPasswordStack: UIStackView!
    @IBOutlet weak var emailAddress: ValidatedTextField!
    @IBOutlet weak var successStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        successStack.visibility = .gone
    }
    @IBAction func sendNewPassword(_ sender: Any) {
        validateAndSend()
    }
    @IBAction func sendNewPasswordAgain(_ sender: Any) {
        validateAndSend()
    }
    @IBAction func goToLogin(_ sender: Any) {
    }
    
    func validateAndSend(){
        if emailAddress.text!.isValidEmail() {
            sendNewPasswordS()
        } else {
            self.emailAddress.validationText = "Please enter a valid email address"
        }
    }
}

extension ForgotPasswordViewController {
    func sendNewPasswordS(){
        let endpointUrl = URL(string: SERVER + "/send_new_password/\(emailAddress.text!)/")!
        var request = URLRequest(url: endpointUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        presentTransparentLoader()
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
            self.closeTransparentLoader()
            guard let data = data else {return}
            do {
                USER = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.successStack.visibility = .visible
                    self.sendNewPasswordStack.visibility = .gone
                }
            } catch _ {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                    DispatchQueue.main.async {
                        self.emailAddress.validationText = json["error_message"] as? String
                    }
                }catch _ {}
            }
        })
        task.resume()
    }
}
