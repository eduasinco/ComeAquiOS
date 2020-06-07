//
//  SplashViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 14/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import Firebase

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        if USER == nil {
            getMyUser()
        } else {
            self.registerFCMDevice()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReviewHostSegue" {
            let vc = segue.destination as? ReviewHostViewController
            vc?.order = sender as? OrderObject
        }
    }
}

extension SplashViewController {
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
                self.registerFCMDevice()
            } catch _ {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LoginOrRegisterSegue", sender: nil)
                }
            }
        })
    }
    func registerFCMDevice(){
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                Server.post("/fcm/v1/devices/",
                            json:
                    ["dev_id":  UIDevice.current.identifierForVendor!.uuidString,
                     "reg_id":  result.token,
                     "name":  "\(USER.id!)"],
                            finish: {(data: Data?, response: URLResponse?) -> Void in
                                self.getMyUnreviewedOrdersAsDinner()
                })
            }
        }
    }
    func getMyUnreviewedOrdersAsDinner(){
        Server.get("/my_unreviewed_order_post/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            guard let data = data else {
                return
            }
            do {
                let orders = try JSONDecoder().decode([OrderObject].self, from: data)
                if orders.count > 0 {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "ReviewHostSegue", sender: orders[0])
                    }
                } else {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "MainSegue", sender: nil)
                    }
                }
            } catch _ {
            }
        })
    }
    func getMyUnreviewedOrders(){
        Server.get("/my_unreviewed_order_post/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            guard let data = data else {
                return
            }
            do {
                let orders = try JSONDecoder().decode([OrderObject].self, from: data)
                if orders.count > 0 {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "ReviewHostSegue", sender: orders[0])
                    }
                }
            } catch _ {
            }
        })
    }
}
