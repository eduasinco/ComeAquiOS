//
//  DistanceViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class DistanceViewController: UIViewController {

    @IBOutlet weak var sliderView: UISlider!
    
    var delegate: FilterDelegate?
    
    @IBOutlet weak var distanceText: UILabel!
    var distance: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        sliderView.setValue(Float(distance!), animated: false)
        guard let dist = distance else {return}
        distanceText.text = "\(dist)m"
    }
    @IBAction func slider(_ sender: UISlider) {
        distance = Int(sender.value)
        distanceText.text = "\(distance!)m"
    }
    @IBAction func apply(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        delegate?.distance(distance: distance!)
    }
}
