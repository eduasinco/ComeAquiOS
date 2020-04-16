//
//  TableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var foodInfoView: UIStackView!
    @IBOutlet weak var plateNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
 
    
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var vegetarian: UIImageView!
    @IBOutlet weak var vegan: UIImageView!
    @IBOutlet weak var wheat: UIImageView!
    @IBOutlet weak var spyci: UIImageView!
    @IBOutlet weak var fish: UIImageView!
    @IBOutlet weak var meat: UIImageView!
    @IBOutlet weak var diary: UIImageView!
    
    @IBOutlet weak var vegetarianWidth: NSLayoutConstraint!
    @IBOutlet weak var veganWidth: NSLayoutConstraint!
    @IBOutlet weak var wheatWidth: NSLayoutConstraint!
    @IBOutlet weak var spyciWidth: NSLayoutConstraint!
    @IBOutlet weak var fishWidth: NSLayoutConstraint!
    @IBOutlet weak var meatWidth: NSLayoutConstraint!
    @IBOutlet weak var diaryWidth: NSLayoutConstraint!
    
    
        
    @IBOutlet weak var foodImageView: CellImageView!
    @IBOutlet weak var heightImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var insideCardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        insideCardView.roundCorners(radius: 4)
        // Initialization code
    }
    
    func setFoodPostType(type: String){
        let typeImages = [vegetarian, vegan, wheat, spyci, fish, meat, diary]
        let typeWidths = [vegetarianWidth, veganWidth, wheatWidth, spyciWidth, fishWidth, meatWidth, diaryWidth]
        
        for (i, c) in type.enumerated(){
            if c == "1" {
                typeImages[i]!.isHidden = false
                typeWidths[i]!.constant = 12
            } else if c == "0"{
                typeImages[i]!.isHidden = true
                typeWidths[i]!.constant = 0
            }
        }
        contentView.layoutIfNeeded()
    }
    
    func putImage(url: String){
        foodImageView.loadImageUsingUrlString(urlString: SERVER + url)
        foodImageView.isHidden = false
        heightImageConstraint.constant = 100
        contentView.layoutIfNeeded()
    }
    
    func hideImage(){
        foodImageView.isHidden = true
        heightImageConstraint.constant = 0
        contentView.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

