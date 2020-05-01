//
//  LoginOrRegisterViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class LoginOrRegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        login()
        // Do any additional setup after loading the view.
    }
    
    func login(){
        Server.get("/login/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
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
        })
    }

}
