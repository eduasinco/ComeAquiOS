//
//  PriceViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class PriceViewController: UIViewController {
    
    var delegate: FilterDelegate?
    @IBOutlet weak var low: UIButton!
    @IBOutlet weak var medium: UIButton!
    @IBOutlet weak var high: UIButton!
    
    var priceType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors(pressed: [low, medium, high][priceType])
    }
    
    func setColors(pressed: UIButton) {
        for b in [low, medium, high]{
            if b == pressed {
                b!.backgroundColor = UIColor.gray
                b!.tintColor = UIColor.white
            } else {
                b!.backgroundColor = UIColor.white
                b!.tintColor = UIColor.gray
            }
        }
    }
    
    @IBAction func low(_ sender: Any) {
        priceType = 0
        setColors(pressed: low)
    }
    @IBAction func medium(_ sender: Any) {
        priceType = 1
        setColors(pressed: medium)
        
    }
    @IBAction func high(_ sender: Any) {
        priceType = 2
        setColors(pressed: high)
    }
    
    @IBAction func apply(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        delegate?.price(price: priceType)
    }
}
