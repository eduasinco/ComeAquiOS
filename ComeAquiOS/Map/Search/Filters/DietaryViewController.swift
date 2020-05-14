//
//  DietaryViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class DietaryViewController: CardBehaviourViewController {
    
    @IBOutlet weak var cardView: UIView!
    
    var delegate: FilterDelegate?
    var type: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func apply(_ sender: Any) {
        moveCardToBottom(view: cardView, onFinish: {() -> Void in})
        delegate?.dietary(type: type!)
        addBottomCardBehaviour(view: cardView, backGround: self.view, onHide: {() -> Void in })

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
