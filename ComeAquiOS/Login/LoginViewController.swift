//
//  LoginViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

var USER: User!

class LoginViewController: KUIViewController, UIScrollViewDelegate {

    @IBOutlet weak var emailText: ValidatedTextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: LoadingButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var holderBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        self.bottomConstraintForKeyboard = holderBottomConstraint
    }
    
    @IBAction func loginPress(_ sender: Any) {
        login()
    }
    func login(){
        let defaults = UserDefaults.standard
        defaults.set(emailText.text!, forKey: "username")
        defaults.set(passwordText.text!, forKey: "password")
        loginButton.showLoading()
        Server.get("/login/"){ data, response, error in
            DispatchQueue.main.async {
                self.loginButton.hideLoading()
            }
            if let response = response as? HTTPURLResponse , !(200...299 ~= response.statusCode) {
                DispatchQueue.main.async {
                    self.emailText.validationText = "Wrong username or password"
                }
            }

            if let _ = error {
                DispatchQueue.main.async {
                    self.emailText.validationText = "No intetnet connection"
                }
            }
            guard let data = data else {return}
            do {
                USER = try JSONDecoder().decode(User.self, from: data)
                guard let _ = USER.id else { return }
                DispatchQueue.main.async {
                    if let eULAAgree = UserDefaults.standard.string(forKey: "EULA"), eULAAgree == "AGREE" {
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    } else {
                        self.performSegue(withIdentifier: "EULASegue", sender: nil)
                    }
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        }
    }
}
