//
//  SortViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class SortViewController: UIViewController {

    var delegate: FilterDelegate?
    @IBOutlet weak var forYou: UIButton!
    @IBOutlet weak var popular: UIButton!
    @IBOutlet weak var rating: UIButton!
    
    var sortType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors(pressed: [forYou, popular, rating][sortType])
    }
    
    func setColors(pressed: UIButton) {
        for b in [forYou, popular, rating] {
            if b == pressed {
                b!.backgroundColor = UIColor.gray
                b!.tintColor = UIColor.white
            } else {
                b!.backgroundColor = UIColor.white
                b!.tintColor = UIColor.gray
            }
        }
    }
    
    @IBAction func foryou(_ sender: Any) {
        sortType = 0
        setColors(pressed: forYou)
    }
    @IBAction func popular(_ sender: Any) {
        sortType = 1
        setColors(pressed: popular)

    }
    @IBAction func rating(_ sender: Any) {
        sortType = 2
        setColors(pressed: rating)
    }
    
    @IBAction func apply(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        delegate?.sort(sortType: sortType)
    }
}
