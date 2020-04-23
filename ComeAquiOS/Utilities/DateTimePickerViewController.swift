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
    func invalidStartDate()
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
    
    var planeDate: Date?
    var automaticStartDate: Date?
    var automaticEndDate: Date?
    
    var startHours: Int = 18
    var startMinutes: Int = 0
    var endHours: Int = 19
    var endMinutes: Int = 30
    
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
    
    func setAutomaticTimes(date: Date = Date()){
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm aa"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        planeDate = Date.startOfToday(date: date)
        
        let calendar = Calendar.current
        startDate = calendar.date(byAdding: .hour, value: startHours, to: planeDate!)
        startDate = calendar.date(byAdding: .minute, value: startMinutes, to: startDate!)
        endDate = calendar.date(byAdding: .hour, value: endHours, to: planeDate!)
        endDate = calendar.date(byAdding: .minute, value: endMinutes, to: endDate!)
        
        dateText.text = dateFormatter.string(from: planeDate!)
        startTimeText.text = hourFormatter.string(from: startDate!)
        endTimeText.text = hourFormatter.string(from: endDate!)
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "MM/dd/yyyy HH:mm aa"
        print(dateTimeFormatter.string(from: startDate!), dateTimeFormatter.string(from: endDate!))
        
        if startingDateIsValid() {
            delegate?.datesPicked(startDate: startDate!, endDate: endDate!)
        } else {
            delegate?.invalidStartDate()
        }
    }
    
    func startingDateIsValid() -> Bool{
        let calendar = Calendar.current
        let in30Minutes = calendar.date(byAdding: .minute, value: 30, to: Date())
        return startDate! > in30Minutes!
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        setAutomaticTimes(date: datePicker.date)
    }
    
    @objc func timeChangedStart(_ datePicker: UIDatePicker) {
        startHours = Calendar.current.component(.hour, from: datePicker.date)
        startMinutes = Calendar.current.component(.minute, from: datePicker.date)
        if let planeDate = self.planeDate {
            setAutomaticTimes(date: planeDate)
        } else {
            setAutomaticTimes()
        }
    }
    
    @objc func timeChangedEnd(_ datePicker: UIDatePicker) {
        endHours = Calendar.current.component(.hour, from: datePicker.date)
        endMinutes = Calendar.current.component(.minute, from: datePicker.date)
        if let planeDate = self.planeDate {
            setAutomaticTimes(date: planeDate)
        } else {
            setAutomaticTimes()
        }
    }
    
        @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
    //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
    //        view.addGestureRecognizer(tapGesture)
            view.endEditing(true)
        }
}
