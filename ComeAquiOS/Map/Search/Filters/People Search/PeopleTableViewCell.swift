//
//  PeopleTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: CellImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(user: User){
        userImage.loadImageUsingUrlString(urlString: user.profile_photo, secondImage: UIImage(systemName: "person.circle"))
        userName.text = user.full_name
        userUsername.text = user.username
    }
}
