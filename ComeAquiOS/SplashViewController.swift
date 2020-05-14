//
//  SplashViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 14/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMyUser()
    }
    
    func getMyUser(){
        Server.get("/login/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            guard let data = data else {
                return
            }
            do {
                USER = try JSONDecoder().decode(User.self, from: data)
                guard let _ = USER.id else {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "LoginOrRegisterSegue", sender: nil)
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "MainSegue", sender: nil)
                }
            } catch _ {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LoginOrRegisterSegue", sender: nil)
                }
            }
        })
    }
    
}
