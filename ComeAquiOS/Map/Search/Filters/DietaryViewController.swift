//
//  DietaryViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class DietaryViewController: UIViewController {
    
    var delegate: FilterDelegate?
    var type: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func apply(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        delegate?.dietary(type: type!)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypesSegue" {
            let vc = segue.destination as? TypesViewController
            vc?.delegate = self
            vc?.initialTypesString = type
        }
    }
}

extension DietaryViewController: TypesProtocol {
    func typeChanged(types: String) {
        self.type = types
    }
}
