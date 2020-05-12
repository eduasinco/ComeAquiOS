//
//  Tab1TableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 08/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol Tab1Delegate {
    func touched(foodPost: FoodPostObject)
}

class Tab1TableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var foodInfoView: UIStackView!
    @IBOutlet weak var plateNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var vegetarian: UIImageView!
    @IBOutlet weak var vegan: UIImageView!
    @IBOutlet weak var wheat: UIImageView!
    @IBOutlet weak var spyci: UIImageView!
    @IBOutlet weak var fish: UIImageView!
    @IBOutlet weak var meat: UIImageView!
    @IBOutlet weak var diary: UIImageView!
    
    @IBOutlet weak var foodImageView: CellImageView!
    @IBOutlet weak var heightImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainBackground: CardView!
    @IBOutlet weak var shadowLayer: UIView!
    
    var foodPost: FoodPostObject?
    var delegate: Tab1Delegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))

    }
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.touched(foodPost: self.foodPost!)
    }
    
    func setFoodPostType(type: String){
        let typeImages = [vegetarian, vegan, wheat, spyci, fish, meat, diary]
        for (i, c) in type.enumerated(){
            if c == "1" {
                typeImages[i]!.visibility = .visible
            } else if c == "0"{
                typeImages[i]!.visibility = .goneX
            }
        }
        contentView.layoutIfNeeded()
    }
    
    func putImage(url: String){
        foodImageView.loadImageUsingUrlString(urlString: url)
        foodImageView.isHidden = false
        heightImageConstraint.constant = 100
        contentView.layoutIfNeeded()
    }
    
    func hideImage(){
        foodImageView.isHidden = true
        heightImageConstraint.constant = 0
        contentView.layoutIfNeeded()
    }
    
    func setCell(_ object: FoodPostObject){
        self.foodPost = object
        self.plateNameLabel.text = object.plate_name
        self.descriptionLabel.text = object.description
        self.timeLabel.text = Date.hhmmHappenedNowTodayYesterdayWeekDay(start: object.start_time!, end: object.end_time!)
        self.priceLabel.text = "$" + String(format:"%.2f", Double(object.price!) / 100)
        self.setFoodPostType(type: object.food_type ?? "0000000")
        
        self.mainBackground.layer.cornerRadius = 8
        self.mainBackground.layer.masksToBounds = true

        if object.images!.count > 0{
            guard let imageString = object.images![0].food_photo else {return}
            self.putImage(url: imageString)
        } else {
            self.hideImage()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
