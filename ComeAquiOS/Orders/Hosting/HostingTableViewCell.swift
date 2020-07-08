//
//  HostingTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 29/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class HostingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var foodPhoto: CellImageView!
    @IBOutlet weak var plateName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var stillNotFinished: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(foodPost: FoodPostObject){
        if foodPost.images!.count > 0 {
            foodPhoto.loadImageUsingUrlString(urlString: foodPost.images![0].food_photo_)
        } else {
            foodPhoto.image = UIImage(named: "empty_plate")
        }
        if let plate_name = foodPost.plate_name, !plate_name.isEmpty {
            plateName.text = plate_name
        } else {
            plateName.text = "Add a title"
        }
        if let startTime = foodPost.time_to_show {
            time.text = startTime
            time.visibility = .visible
        } else {
            time.visibility = .goneY
        }
        if
            foodPost.plate_name == nil ||
            foodPost.lat == nil ||
            foodPost.lng == nil ||
            foodPost.max_dinners == nil ||
            foodPost.time_to_show == nil ||
            foodPost.end_time == nil ||
            foodPost.price == nil ||
            foodPost.description == nil{
            stillNotFinished.visibility = .visible
        } else {
            if foodPost.visible! {
                stillNotFinished.visibility = .goneY
            } else {
                stillNotFinished.visibility = .visible
                stillNotFinished.text = "Not posted yet"
            }
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
