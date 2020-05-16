//
//  MessageTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var leftMessageConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightMessageConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(message: MessageObject) {
        messageView.text = message.message
        if message.sender!.id == USER.id {
            leftMessageConstraint?.isActive = false
            rightMessageConstraint?.isActive = true
        } else {
            leftMessageConstraint?.isActive = true
            rightMessageConstraint?.isActive = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
