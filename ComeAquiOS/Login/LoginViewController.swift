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
    
        Server.get("/login/", finish: {
            (data: Data?) -> Void in
            guard let data = data else {
                return
            }
            do {
                USER = try JSONDecoder().decode(User.self, from: data)
                guard let _ = USER.id else { return }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "GoToMainSegue", sender: nil)
                }
            } catch let jsonErr {
                print("json could'nt be parsed \(jsonErr)")
            }
        }, error: {(data: Data?) -> Void in
            DispatchQueue.main.async {
                self.emailText.validationText = "Wrong username or password"
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToMainSegue"{
        }
    }
}
