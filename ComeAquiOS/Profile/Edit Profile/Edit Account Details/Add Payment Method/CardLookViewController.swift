//
//  CardLookViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 11/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
private class ResponseObject: Decodable {
    var error_message: String?
    var data: [PaymentMethodObject]?
}

class CardLookViewController: LoadViewController {
    
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardExpiryDate: UILabel!
    
    var paymentMethod: PaymentMethodObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardNumber.text = paymentMethod?.last4
        cardExpiryDate.text = "\(paymentMethod!.exp_month!)/ \(paymentMethod!.exp_year!)"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OptionsSegue" {
            let optionsVC = segue.destination as? OptionsPopUpViewController
            optionsVC?.delegate = self
            optionsVC?.options = ["Set as deault", "Delete"]
        }
    }
}

extension CardLookViewController: OptionsPopUpProtocol {
    func optionPressed(_ title: String) {
        switch title {
        case "Set as deault":
            selectAsPaymentMethod()
            break
        case "Delete":
            deleteCard()
            break
        default:
            break
        }
    }
}

extension CardLookViewController {
    func selectAsPaymentMethod(){
        guard let paymentMethod = self.paymentMethod else {return}
        
        Server.patch("/select_as_payment_method/" + paymentMethod._id! + "/",
                     json: ["": ""]) { data, response, error in
                        if let _ = error {
                            self.view.showToast(message: "No internet connection")
                        }
                        guard data != nil else {
                            return
                        }
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
        }
    }
    
    func deleteCard(){
        guard let paymentMethod = self.paymentMethod else {return}
        Server.delete("/card_detail/" + paymentMethod._id! + "/"){ data, response, error in
            DispatchQueue.main.async {
                
            }
            guard let data = data else {
                return
            }
            do {
                let responseO = try JSONDecoder().decode(ResponseObject.self, from: data)
                if responseO.error_message == nil {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        }
    }
}


