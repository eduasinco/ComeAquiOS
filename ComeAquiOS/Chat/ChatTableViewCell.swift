//
//  ChatTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: CellImageView!
    @IBOutlet weak var userUsername: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var lastMessageText: UILabel!
    @IBOutlet weak var unreadMessagesCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(chat: ChatObject){
        let chattingWith = (USER.id == chat.users![0].id) ? chat.users![1] : chat.users![0]

        userUsername.text = chattingWith.full_name
        if let lastMessage = chat.last_message{
            lastMessageText.text = lastMessage.message
        } else {
            lastMessageText.text = nil
        }
//        if let userCount = chat.user_chat_s![USER.id], userCount > 0 {
//            unreadMessagesCount.visibility = .visible
//            unreadMessagesCount.text = "\(userCount)"
//        } else {
//            unreadMessagesCount.visibility = .invisible
//        }

        userImage.loadImageUsingUrlString(urlString: chattingWith.profile_photo!)

        if chat.last_message != nil {
            date.text = chat.last_message?.created_at
        } else {
            date.text = chat.created_at
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}