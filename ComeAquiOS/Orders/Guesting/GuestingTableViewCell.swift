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
        posterImage.loadImageUsingUrlString(urlString: order.poster!.profile_photo!)
        posterName.text = order.poster?.full_name
        orderStatus.text = order.order_status
        plateName.text = order.post?.plate_name
        location.text = order.post?.formatted_address
        dateAndTime.text = order.post!.start_time! + " $-" + order.post!.price!.format()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
