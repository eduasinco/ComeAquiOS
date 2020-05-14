//
//  MealTimeViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class MealTimeViewController: CardBehaviourViewController {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    var delegate: FilterDelegate?

    var startDate: String?
    var endDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = bottomViewConstraint
        addBottomCardBehaviour(view: cardView, backGround: self.view, onHide: {() -> Void in })

    }
    @IBAction func apply(_ sender: Any) {
        moveCardToBottom(view: cardView, onFinish: {() -> Void in})
        delegate?.mealTime(startTime: startDate!, endTime: endDate!)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DateTimeSegue" {
            let vc = segue.destination as? DateTimePickerViewController
            vc?.delegate = self
        }
    }
}

extension MealTimeViewController: DatePickerProtocol {
    func datesPicked(startDate: String, endDate: String) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func invalidStartDate() {
        
    }
}
