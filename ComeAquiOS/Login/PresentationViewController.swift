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
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var codeDidNotArriveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        message.text! += USER.full_name!
        codeView.delegate = self
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
        let endpointUrl = URL(string: SERVER + "/send_verification_code/\(USER.email!)/" + (codeView.text!.isEmpty ?  "0": codeView.text!) + "/")!
        var request = URLRequest(url: endpointUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        presentTransparentLoader()
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
            self.closeTransparentLoader()
            guard let data = data else {return}
            if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                do {
                    USER = try JSONDecoder().decode(User.self, from: data)
                } catch _ {
                    self.view.showToast(message: "Something went wrong")
                }
                DispatchQueue.main.async {
                    self.goToLoginView.visibility = .visible
                    self.codeView.isEnabled = false
                    self.sendCodeButton.isEnabled = false
                    self.codeDidNotArriveButton.isEnabled = false
                    self.view.endEditing(true)
                }
            } else if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                DispatchQueue.main.async {
                    self.codeView.validationText = "Wrong verfication code"
                }
            } else {
                self.view.showToast(message: "Something went wrong")
            }
        })
        task.resume()
    }
}

extension PresentationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 6
    }
}
