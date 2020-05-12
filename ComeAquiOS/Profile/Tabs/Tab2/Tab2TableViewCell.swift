//
//  Tab2TableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 08/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class Tab2TableViewCell: UITableViewCell {
    
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
    
    @IBOutlet weak var reviewerView: UIView!
    @IBOutlet weak var reviewerImage: CellImageView!
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var reviewerMessage: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
            foodImageView.loadImageUsingUrlString(urlString: imageString)
            foodImageView.visibility = .visible
        } else {
            foodImageView.visibility = .gone
        }
        
        if object.reviews!.count > 0 && object.reviews![0].id != nil {
            reviewerView.visibility = .visible
            reviewerImage.loadImageUsingUrlString(urlString: object.reviews![0].owner!.profile_photo!)

            reviewerName.text = object.reviews![0].owner!.username
            reviewerMessage.text = object.reviews![0].review
        } else {
            reviewerView.visibility = .gone
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
