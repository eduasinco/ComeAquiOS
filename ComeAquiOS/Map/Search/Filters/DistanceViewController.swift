//
//  DistanceViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class DistanceViewController: CardBehaviourViewController {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var sliderView: UISlider!
    
    var delegate: FilterDelegate?
    
    @IBOutlet weak var distanceText: UILabel!
    var distance: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        sliderView.setValue(Float(distance!), animated: false)
        addBottomCardBehaviour(view: cardView, backGround: self.view, onHide: {() -> Void in })

        guard let dist = distance else {return}
        distanceText.text = "\(dist)m"
    }
    @IBAction func slider(_ sender: UISlider) {
        distance = Int(sender.value)
        distanceText.text = "\(distance!)m"
    }
    @IBAction func apply(_ sender: Any) {
        moveCardToBottom(view: cardView, onFinish: {() -> Void in })
        delegate?.distance(distance: distance!)
    }
}
