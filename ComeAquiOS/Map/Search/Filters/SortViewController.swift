//
//  SortViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class SortViewController: CardBehaviourViewController {

    var delegate: FilterDelegate?
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var forYou: UIButton!
    @IBOutlet weak var popular: UIButton!
    @IBOutlet weak var rating: UIButton!
    
    var sortType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors(pressed: [forYou, popular, rating][sortType])
        addBottomCardBehaviour(view: cardView, backGround: self.view, onHide: {() -> Void in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func setColors(pressed: UIButton) {
        for b in [forYou, popular, rating] {
            if b == pressed {
                b!.backgroundColor = UIColor.gray
                b!.tintColor = UIColor.white
                b!.setTitleColor(UIColor.white, for: .normal)

            } else {
                b!.backgroundColor = UIColor.white
                b!.tintColor = UIColor(named: "Secondary")
                b!.setTitleColor(UIColor.gray, for: .normal)

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
        moveCardOut(view: cardView, onFinish: {() -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        delegate?.sort(sortType: sortType)
    }
}
