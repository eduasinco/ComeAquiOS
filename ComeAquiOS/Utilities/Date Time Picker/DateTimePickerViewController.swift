//
//  DateTimePickerViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 21/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol DatePickerProtocol{
    func datesPicked(startDate: String, endDate: String)
    func invalidStartDate()
}

class DateTimePickerViewController: UIViewController {
    @IBOutlet weak var dateText: ValidatedTextField!
    @IBOutlet weak var startTimeText: ValidatedTextField!
    @IBOutlet weak var endTimeText: ValidatedTextField!
    
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
    
    let hourFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    
    func setDateTime(startDateString: String, endDateString: String){
        startDate = Date.convertToDate(isoDateString: startDateString)
        endDate = Date.convertToDate(isoDateString: endDateString)
        
        startHours = Calendar.current.component(.hour, from: startDate!)
        startMinutes = Calendar.current.component(.minute, from: startDate!)
        endHours = Calendar.current.component(.hour, from: endDate!)
        endMinutes = Calendar.current.component(.minute, from: endDate!)
        
        setAutomaticTimes(date: startDate!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        hourFormatter.dateFormat = "HH:mm aa"
        dateFormatter.dateFormat = "MM/dd/yyyy"

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
            let dateTimeFormatter = DateFormatter()
            dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            print(dateTimeFormatter.string(from: startDate!), dateTimeFormatter.string(from: endDate!))
            delegate?.datesPicked(startDate: dateTimeFormatter.string(from: startDate!), endDate: dateTimeFormatter.string(from: endDate!))
        } else {
            delegate?.invalidStartDate()
        }
    }
    
    func startingDateIsValid() -> Bool{
        let calendar = Calendar.current
        let in30Minutes = calendar.date(byAdding: .minute, value: 0, to: Date())
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
