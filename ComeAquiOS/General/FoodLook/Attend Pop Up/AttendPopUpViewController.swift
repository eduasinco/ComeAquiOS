//
//  AttendPopUpViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 28/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol AttendMealProtocol {
    func confirmAttend(additionalGuests: Int)
}

class AttendPopUpViewController: UIViewController {

    @IBOutlet weak var priceText: UILabel!
    @IBOutlet weak var additionalGuestsText: UILabel!
    
    var additionalGuests = 0
    var dinners_left: Int!
    var price: Int!
    
    var delegate: AttendMealProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceText.text = "$" + (price / 100).format()
    }
    @IBAction func minusPressed(_ sender: Any) {
        if (additionalGuests > 0){
            additionalGuests -= 1
            priceText.text = "$" + (price * (1 + additionalGuests) / 100).format()
            
        }
        additionalGuestsText.text = "\(additionalGuests)"
    }
    @IBAction func plusPressed(_ sender: Any) {
        if (additionalGuests < dinners_left - 1){
            additionalGuests += 1
            priceText.text = "$" + (price * (1 + additionalGuests) / 100).format()
        }
        additionalGuestsText.text = "\(additionalGuests)"
    }
    @IBAction func confirmPressed(_ sender: Any) {
        delegate?.confirmAttend(additionalGuests: Int(additionalGuestsText.text!)!)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first!
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != self.view {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }}
