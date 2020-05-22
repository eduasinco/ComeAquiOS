//
//  DinnerTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 19/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class DinnerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: URLImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNamelabel: UILabel!
    @IBOutlet weak var chatButton: UIImageView!
    @IBOutlet weak var additionalGuestsLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        chatButton.isUserInteractionEnabled = true
        let tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: Selector(("tappedView")))
        chatButton.addGestureRecognizer(tapRec)

    }

    func tappedView(){
        print("go to chat with user")
    }
    
    func setCell(order: OrderObject){
        profileImageView.loadImageUsingUrlString(urlString: order.owner!.profile_photo)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
