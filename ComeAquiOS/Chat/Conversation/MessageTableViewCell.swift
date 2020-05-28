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
    @IBOutlet var leftMessageConstraint: NSLayoutConstraint!
    @IBOutlet var rightMessageConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(message: MessageObject, messageBefore: MessageObject?) {
        messageView.text = message.message
        
        messageView.layer.cornerRadius = 0
        messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        if message.sender!.id == USER.id {
            leftMessageConstraint?.isActive = false
            rightMessageConstraint?.isActive = true
            messageView.backgroundColor = UIColor.lightGray
            messageView.backgroundColor = UIColor(named: "SecondaryLighter")
            
            if messageBefore != nil && messageBefore?.sender!.id == message.sender!.id {
                messageView.layer.cornerRadius = 8
                messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                messageView.layer.cornerRadius = 8
                messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            }
        } else {
            leftMessageConstraint?.isActive = true
            rightMessageConstraint?.isActive = false
            messageView.backgroundColor = UIColor(named: "PrimaryLighter")
            
            if messageBefore != nil && messageBefore?.sender!.id == message.sender!.id {
                messageView.layer.cornerRadius = 8
                messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                messageView.layer.cornerRadius = 8
                messageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
