//
//  NotificationTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 29/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var dinnerImage: CellImageView!
    @IBOutlet weak var notificationTypeImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var notificationText: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(notification: NotificationObject){
        username.text = notification.from_user?.username
        notificationText.text = notification.title
        body.text = notification.body
        date.text = notification.createdAt
        
        if let profile_photo = notification.from_user?.profile_photo{
            dinnerImage.loadImageUsingUrlString(urlString: profile_photo)
        } else {
            dinnerImage.image = UIImage(named: "poster")
        }

        switch notification.type {
        case "PENDING":
            break
        case "CONFIRMED":
            break
        case "REJECTED":
            break
        case "CANCELED":
            break
        case "REVIEW":
            break
        case "COMMENT":
            break
        case "INFO":
            break
        default:
            break
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
