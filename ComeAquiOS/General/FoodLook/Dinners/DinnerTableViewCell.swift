//
//  DinnerTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 19/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
protocol DinnderCellDelegate {
    func chatButtonPressed(order: OrderObject)
}

class DinnerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: CellImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNamelabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var additionalGuestsLabel: UILabel!
    
    var order: OrderObject?
    var delegate: DinnderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func chatTapped(_ sender: Any) {
        guard let order = self.order else {return}
        delegate?.chatButtonPressed(order: order)
    }
    
    func setCell(order: OrderObject){
        self.order = order
        profileImageView.loadImageUsingUrlString(urlString: order.owner!.profile_photo_, secondImage: UIImage(systemName: "person.circle"))
        nameLabel.text = order.owner?.full_name
        userNamelabel.text = order.owner?.username
        if order.additional_guests ?? 0 > 0{
            additionalGuestsLabel.text = " \(order.additional_guests!)+ "
        } else {
            additionalGuestsLabel.text = ""
        }
        if order.owner?._id == USER._id {
            chatButton.visibility = .gone
        } else {
            chatButton.visibility = .visible
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
