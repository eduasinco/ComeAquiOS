//
//  AllViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol FilterDelegate {
    func sort(sortType: Int)
    func price(price: Int)
    func mealTime(startTime: String, endTime: String)
    func distance(distance: Int)
    func dietary(type: String)
}

class AllViewController: KUIViewController {

    var delegate: FilterDelegate?
    @IBOutlet weak var forYou: UIButton!
    @IBOutlet weak var popular: UIButton!
    @IBOutlet weak var rating: UIButton!
    
    var sortType: Int = 0
    
    
    @IBOutlet weak var low: UIButton!
    @IBOutlet weak var medium: UIButton!
    @IBOutlet weak var high: UIButton!
    
    var priceType: Int = 0
    
    
    var dateTimeVC: DateTimePickerViewController?
    var startDateString: String?
    var endDateString: String?
    
    
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var distanceText: UILabel!
    var distance: Int?
        
    var type: String?
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors(pressed: [forYou, popular, rating][sortType])
        
        setColors2(pressed: [low, medium, high][priceType])
        
        guard let startDate = self.startDateString, let endDate = endDateString else {return}
        dateTimeVC?.setDateTime(startDateString: startDate, endDateString: endDate)
        
        sliderView.setValue(Float(distance!), animated: false)
        guard let dist = distance else {return}
        distanceText.text = "\(dist)m"
        
        bottomConstraintForKeyboard = bottomViewConstraint
    }
    
    func setColors(pressed: UIButton) {
        for b in [forYou, popular, rating] {
            if b == pressed {
                b!.backgroundColor = UIColor.gray
                b!.tintColor = UIColor.white
            } else {
                b!.backgroundColor = UIColor.white
                b!.tintColor = UIColor.gray
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

    func setColors2(pressed: UIButton) {
        for b in [low, medium, high]{
            if b == pressed {
                b!.backgroundColor = UIColor.gray
                b!.tintColor = UIColor.white
            } else {
                b!.backgroundColor = UIColor.white
                b!.tintColor = UIColor.gray
            }
        }
    }
    @IBAction func low(_ sender: Any) {
        priceType = 0
        setColors2(pressed: low)
    }
    @IBAction func medium(_ sender: Any) {
        priceType = 1
        setColors2(pressed: medium)
        
    }
    @IBAction func high(_ sender: Any) {
        priceType = 2
        setColors2(pressed: high)
    }
    
    @IBAction func apply(_ sender: Any) {
        guard let startDate = self.startDateString, let endDate = endDateString else {
            self.view.showToast(message: "Please select a time greater than now")
            return
        }
        delegate?.sort(sortType: sortType)
        delegate?.price(price: priceType)
        delegate?.mealTime(startTime: startDate, endTime: endDate)
        delegate?.distance(distance: distance!)
        delegate?.dietary(type: type!)
    }
    
    @IBAction func slider(_ sender: UISlider) {
        distance = Int(sender.value)
        distanceText.text = "\(distance!)m"
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypesSegue" {
            let vc = segue.destination as? TypesViewController
            vc?.delegate = self
            vc?.initialTypesString = type
        } else if segue.identifier == "DateTimeSegue" {
            dateTimeVC = segue.destination as? DateTimePickerViewController
            dateTimeVC?.delegate = self
        }
    }
}

extension AllViewController: DatePickerProtocol {
    func datesPicked(startDate: String, endDate: String) {
        self.startDateString = startDate
        self.endDateString = endDate
    }
    
    func invalidStartDate() {
    }
}

extension AllViewController: TypesProtocol {
    func typeChanged(types: String) {
        self.type = types
    }
}
