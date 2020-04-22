//
//  DateTimePickerViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 21/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol DatePickerProtocol{
    func datesPicked(startDate: Date, endDate: Date)
}

class DateTimePickerViewController: UIViewController {
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var startTimeText: UITextField!
    @IBOutlet weak var endTimeText: UITextField!
    
    private var datePickerForDateText: UIDatePicker?
    private var timePickerForStartText: UIDatePicker?
    private var timePickerForEndText: UIDatePicker?

    var delegate: DatePickerProtocol?
    
    var startDate: Date?
    var endDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerForDateText = UIDatePicker()
        datePickerForDateText?.datePickerMode = .date
        datePickerForDateText?.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        timePickerForStartText = UIDatePicker()
        timePickerForStartText?.datePickerMode = .time
        timePickerForStartText?.addTarget(self, action: #selector(timeChangedStart), for: .valueChanged)
        
        timePickerForEndText = UIDatePicker()
        timePickerForEndText?.datePickerMode = .time
        timePickerForEndText?.addTarget(self, action: #selector(timeChangedEnd(_:)), for: .valueChanged)

        dateText.inputView = datePickerForDateText
        startTimeText.inputView = timePickerForStartText
        endTimeText.inputView = timePickerForEndText
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
//        view.addGestureRecognizer(tapGesture)
        view.endEditing(true)
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateText.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func timeChangedStart(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a"
        startTimeText.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func timeChangedEnd(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a"
        endTimeText.text = dateFormatter.string(from: datePicker.date)
    }
}
