//
//  MessageTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet var leftMessageConstraint: NSLayoutConstraint!
    @IBOutlet var rightMessageConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(message: MessageObject, messageBefore: MessageObject?) {
        messageView.text = message.message
        messageTime.text = message.h
        
        messageContainer.layer.cornerRadius = 0
        messageContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        messageContainer.layer.shadowColor = UIColor.black.cgColor
        messageContainer.layer.shadowOpacity = 0.2
        messageContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        messageContainer.layer.shadowRadius = 0.5
        
        if message.sender!.id == USER.id {
            leftMessageConstraint?.isActive = false
            rightMessageConstraint?.isActive = true
            messageContainer.backgroundColor = UIColor.lightGray
            messageContainer.backgroundColor = UIColor(named: "PrimaryLighter")
            
            if messageBefore != nil && messageBefore?.sender!.id == message.sender!.id {
                messageContainer.layer.cornerRadius = 8
                messageContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                messageContainer.layer.cornerRadius = 8
                messageContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            }
        } else {
            leftMessageConstraint?.isActive = true
            rightMessageConstraint?.isActive = false
            messageContainer.backgroundColor = UIColor(named: "SecondaryLighter")
            
            if messageBefore != nil && messageBefore?.sender!.id == message.sender!.id {
                messageContainer.layer.cornerRadius = 8
                messageContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                messageContainer.layer.cornerRadius = 8
                messageContainer.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
