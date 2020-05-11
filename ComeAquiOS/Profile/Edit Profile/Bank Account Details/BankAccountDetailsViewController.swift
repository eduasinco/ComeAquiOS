//
//  BankAccountDetailsViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 11/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class BankAccountDetailsViewController: UIViewController {

    @IBOutlet weak var firstName: ValidatedTextField!
    @IBOutlet weak var lastName: ValidatedTextField!
    @IBOutlet weak var dateOfBirth: ValidatedTextField!
    @IBOutlet weak var ssn: ValidatedTextField!
    @IBOutlet weak var idValidationText: UILabel!
    @IBOutlet weak var phoneNumber: ValidatedTextField!
    @IBOutlet weak var addressLine1: ValidatedTextField!
    @IBOutlet weak var addressLine2: ValidatedTextField!
    @IBOutlet weak var city: ValidatedTextField!
    @IBOutlet weak var state: ValidatedTextField!
    @IBOutlet weak var zip: ValidatedTextField!
    @IBOutlet weak var country: ValidatedTextField!
    @IBOutlet weak var routingNumber: ValidatedTextField!
    @IBOutlet weak var accountNumber: ValidatedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idValidationText.visibility = .gone
    }
    
    @IBAction func frontId(_ sender: Any) {
    }
    @IBAction func backId(_ sender: Any) {
    }
}

extension BankAccountDetailsViewController {
    
}
