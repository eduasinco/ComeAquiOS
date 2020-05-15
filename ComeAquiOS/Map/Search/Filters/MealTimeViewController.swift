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

    var dateTimeVC: DateTimePickerViewController?
    var startDateString: String?
    var endDateString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = bottomViewConstraint
        addBottomCardBehaviour(view: cardView, backGround: self.view, onHide: {() -> Void in })
        guard let startDate = self.startDateString, let endDate = endDateString else {return}
        dateTimeVC?.setDateTime(startDateString: startDate, endDateString: endDate)
    }
    @IBAction func apply(_ sender: Any) {
        moveCardToBottom(view: cardView, onFinish: {() -> Void in})
        guard let startDate = self.startDateString, let endDate = endDateString else {return}
        delegate?.mealTime(startTime: startDate, endTime: endDate)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DateTimeSegue" {
            dateTimeVC = segue.destination as? DateTimePickerViewController
            dateTimeVC?.delegate = self
        }
    }
}

extension MealTimeViewController: DatePickerProtocol {
    func datesPicked(startDate: String, endDate: String) {
        self.startDateString = startDate
        self.endDateString = endDate
    }
    
    func invalidStartDate() {
        
    }
}
