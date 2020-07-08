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
    @IBOutlet weak var notificationTypeImage: UIButton!
    @IBOutlet weak var fullNameText: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var notificationText: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(notification: NotificationObject){
        fullNameText.text = notification.from_user?.full_name
        username.text = notification.from_user?.username
        notificationText.text = notification.title
        body.text = notification.body
        date.text = notification.createdAt
        dinnerImage.loadImageUsingUrlString(urlString: notification.from_user?.profile_photo_, secondImage: UIImage(systemName: "person.circle"))

        switch notification.type {
        case "PENDING":
            let image = UIImage(systemName: "tray.fill")
            image?.withTintColor(UIColor.white)
            notificationTypeImage.setImage(image, for: .normal)
            notificationTypeImage.backgroundColor = UIColor(named: "Grey")
            break
        case "CONFIRMED":
            let image = UIImage(systemName: "tray.fill")
            image?.withTintColor(UIColor.white)
            notificationTypeImage.setImage(image, for: .normal)
            notificationTypeImage.backgroundColor = UIColor(named: "Success")
            break
        case "REJECTED":
            let image = UIImage(systemName: "tray.fill")
            image?.withTintColor(UIColor.white)
            notificationTypeImage.setImage(image, for: .normal)
            notificationTypeImage.backgroundColor = UIColor(named: "Canceledd")
            break
        case "CANCELED":
            let image = UIImage(systemName: "tray.fill")
            image?.withTintColor(UIColor.white)
            notificationTypeImage.setImage(image, for: .normal)
            notificationTypeImage.backgroundColor = UIColor(named: "Canceledd")
            break
        case "REVIEW":
            let image = UIImage(systemName: "star.fill")
            image?.withTintColor(UIColor.white)
            notificationTypeImage.setImage(image, for: .normal)
            notificationTypeImage.backgroundColor = UIColor(named: "Favourite")
            break
        case "COMMENT":
            let image = UIImage(systemName: "message.fill")
            image?.withTintColor(UIColor.white)
            notificationTypeImage.setImage(image, for: .normal)
            notificationTypeImage.backgroundColor = UIColor.blue
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
