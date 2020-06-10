//
//  GuestingTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 29/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class GuestingTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImage: CellImageView!
    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    @IBOutlet weak var plateName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var dateAndTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(order: OrderObject){
        posterImage.loadImageUsingUrlString(urlString: order.poster!.profile_photo, secondImage: UIImage(systemName: "person.circle"))
        posterName.text = order.poster?.full_name
        orderStatus.text = "  " + order.order_status! + "  "
        plateName.text = order.post?.plate_name
        location.text = order.post?.formatted_address
        dateAndTime.text = order.post!.time_to_show! + " $-" + order.post!.price!.format()
        
        switch order.order_status {
        case "PENDING":
            if let seen = order.seen, seen {
                orderStatus.backgroundColor = UIColor.clear
                orderStatus.textColor = UIColor(named: "Primary")
            } else {
                orderStatus.backgroundColor = UIColor(named: "Primary")
                orderStatus.textColor = UIColor.white
            }
            break
        case "CONFIRMED":
            if let seen = order.seen, seen {
                orderStatus.backgroundColor = UIColor.clear
                orderStatus.textColor = UIColor(named: "Confirm")
            } else {
                orderStatus.backgroundColor = UIColor(named: "Confirm")
                orderStatus.textColor = UIColor.white
            }
            break
        case "REJECTED":
            if let seen = order.seen, seen {
                orderStatus.backgroundColor = UIColor.clear
                orderStatus.textColor = UIColor(named: "Canceledd")
            } else {
                orderStatus.backgroundColor = UIColor(named: "Canceledd")
                orderStatus.textColor = UIColor.white
            }
            break
        case "CANCELED":
            if let seen = order.seen, seen {
                orderStatus.backgroundColor = UIColor.clear
                orderStatus.textColor = UIColor(named: "Secondary")
            } else {
                orderStatus.backgroundColor = UIColor(named: "Secondary")
                orderStatus.textColor = UIColor.white
            }
            break
        case "FINISHED":
            if let seen = order.seen, seen {
                orderStatus.backgroundColor = UIColor.clear
                orderStatus.textColor = UIColor(named: "Primary")
            } else {
                orderStatus.backgroundColor = UIColor(named: "Primary")
                orderStatus.textColor = UIColor.white
            }
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
