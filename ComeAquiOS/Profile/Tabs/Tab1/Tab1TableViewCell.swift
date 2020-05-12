//
//  Tab1TableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 08/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var mainBackground: UIView!
    @IBOutlet weak var shadowLayer: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

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
        self.plateNameLabel.text = object.plate_name
        self.descriptionLabel.text = object.description
        self.timeLabel.text = Date.hhmmHappenedNowTodayYesterdayWeekDay(start: object.start_time!, end: object.end_time!)
        self.priceLabel.text = "$" + String(format:"%.2f", Double(object.price!) / 100)
        self.setFoodPostType(type: object.food_type ?? "0000000")
        
        self.mainBackground.layer.cornerRadius = 8
        self.mainBackground.layer.masksToBounds = true

        self.shadowLayer.layer.cornerRadius = 8
        self.shadowLayer.layer.masksToBounds = false
        
        self.shadowLayer.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.shadowLayer.layer.shadowColor = UIColor.black.cgColor
        self.shadowLayer.layer.shadowOpacity = 0.23
        self.shadowLayer.layer.shadowRadius = 4

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
