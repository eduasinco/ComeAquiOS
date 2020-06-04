//
//  PresentationViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class PresentationViewController: LoadViewController {

    @IBOutlet weak var goToLoginView: UIStackView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var codeView: ValidatedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        message.text! += USER.full_name!
    }
    @IBAction func sendVerificationCodeAgain(_ sender: Any) {
        sendVerificationCodeAgain()
    }
    @IBAction func sendCode(_ sender: Any) {
        sendVerificationCode()
    }
}

extension PresentationViewController {
    
    func sendVerificationCodeAgain(){
        let endpointUrl = URL(string: SERVER + "/send_verification_email_again/\(USER.email!)/")!
        var request = URLRequest(url: endpointUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        presentTransparentLoader()
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
            self.closeTransparentLoader()
        })
        task.resume()
    }
    
    func sendVerificationCode(){
        let endpointUrl = URL(string: SERVER + "/send_verification_code/\(USER.email!)/\(codeView.text!)/")!
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
                    self.goToLoginView.visibility = .visible
                    self.view.endEditing(true)
                }
            } catch _ {
                DispatchQueue.main.async {
                    self.codeView.validationText = "Wrong verificatoin code"
                }
            }
        })
        task.resume()
    }
}
