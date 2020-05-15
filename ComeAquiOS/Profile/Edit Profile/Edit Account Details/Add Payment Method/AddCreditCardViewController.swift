//
//  AddCreditCardViewController.swift
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

class AddCreditCardViewController: LoadViewController {

    @IBOutlet weak var cardNumber: ValidatedTextField!
    @IBOutlet weak var month: ValidatedTextField!
    @IBOutlet weak var year: ValidatedTextField!
    @IBOutlet weak var cvc: ValidatedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        month.delegate = self
        year.delegate = self
    }
    func isValid() -> Bool{
        var valid = true
        if cardNumber.text!.isEmpty {
            cardNumber.validationText = "Insert a valid card number"
            valid = false
        }
        if month.text!.isEmpty {
            month.validationText = "Insert a valid month"
            valid = false
        }
        if year.text!.isEmpty {
            year.validationText = "Insert a valid year"
            valid = false
        }
        if cvc.text!.isEmpty {
            cvc.validationText = "Insert a valid CVC"
            valid = false
        }
        return valid
    }
    @IBAction func saveCard(_ sender: Any) {
        if isValid(){
            saveCard()
        }
    }
}

extension AddCreditCardViewController {
    func saveCard(){
            present(alert, animated: false, completion: nil)
            Server.post("/card/",
                        json:
                [
                    "card_number":  cardNumber.text,
                    "exp_month":  month.text,
                    "exp_year":  year.text,
                    "cvc":  cvc.text
                ],
                        finish: {(data: Data?, response: URLResponse?) -> Void in
                            DispatchQueue.main.async {
                                self.alert.dismiss(animated: false, completion: nil)
                            }
                            guard let data = data else {
                                return
                            }
                            do {
                                let responseO = try JSONDecoder().decode(ResponseObject.self, from: data)
                                if responseO.error_message == nil {
                                    DispatchQueue.main.async {
                                        self.navigationController?.popViewController(animated: true)
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        switch responseO.error_message {
                                        case "number":
                                            self.cardNumber.validationText = "Invalid card number"
                                        case "exp_month":
                                            self.month.validationText = "Invalid month"
                                        case "exp_year":
                                            self.year.validationText = "Invalid year"
                                        case "cvc":
                                            self.cvc.validationText = "Invalid CVC"
                                        default:
                                            break
                                        }
                                    }
                                }
                            } catch _ {
                                self.view.showToast(message: "Some error ocurred")
                            }
            })
        }
}

extension AddCreditCardViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let numberOfChars = newText.count
        if textField == month {
            return numberOfChars <= 2
        } else {
            return numberOfChars <= 4
        }
    }
    
}
