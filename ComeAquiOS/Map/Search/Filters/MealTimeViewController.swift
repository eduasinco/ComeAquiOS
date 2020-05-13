//
//  MealTimeViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class MealTimeViewController: KUIViewController {

    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    var delegate: FilterDelegate?

    var startDate: String?
    var endDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = bottomViewConstraint
    }
    @IBAction func apply(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
