//
//  CommentsTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol AddOrDeleteDelegate {
    func expand(comment: Comment, cell: UITableViewCell)
    func collapse(comment: Comment, cell: UITableViewCell)
    func add(comment: Comment, cell: UITableViewCell)
    func delete(comment: Comment, cell: UITableViewCell)
    func options(comment: Comment, cell: UITableViewCell)
    func moreComments(comment: Comment, cell: UITableViewCell)
    func continueConversation(comment: Comment, cell: CommentsTableViewCell)
}

class CommentsTableViewCell: UITableViewCell {
    
    var tableHeightAnchor: NSLayoutConstraint!
    var comment: Comment?
    @IBOutlet weak var senderImage: CellImageView!
    @IBOutlet weak var senderUsername: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var stackView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var leadingStackView: NSLayoutConstraint!
    
    @IBOutlet weak var moreCommentsButton: UIButton!
    @IBOutlet weak var leadingMoreComments: NSLayoutConstraint!
    
    @IBOutlet weak var continueConversationButton: UIButton!
    @IBOutlet weak var leadingContinueConversation: NSLayoutConstraint!
    
    var delegate: AddOrDeleteDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func addPress(_ sender: Any) {
        self.delegate?.add(comment: self.comment!, cell: self)
    }
    @IBAction func deletePress(_ sender: Any) {
        self.delegate?.delete(comment: self.comment!, cell: self)
    }
    @IBAction func expandPress(_ sender: Any) {
                self.delegate?.expand(comment: self.comment!, cell: self)
    }
    @IBAction func collapsePress(_ sender: Any) {
                self.delegate?.collapse(comment: self.comment!, cell: self)
    }
    @IBAction func continueConversation(_ sender: Any) {
        self.delegate?.continueConversation(comment: self.comment!, cell: self)

    }
    @IBAction func loadMoreComments(_ sender: Any) {
        self.delegate?.moreComments(comment: self.comment!, cell: self)
    }
    @IBAction func options(_ sender: Any) {
        self.delegate?.options(comment: self.comment!, cell: self)
    }
    
    func setCell(comment: Comment, max_depth: Int = 0){
        self.comment = comment
        leadingStackView.constant = CGFloat((comment.depth - max_depth) * 32)
        leadingMoreComments.constant = CGFloat((comment.depth - max_depth) * 32)
        leadingContinueConversation.constant = CGFloat((comment.depth - max_depth) * 32)
        
        senderImage.loadImageUsingUrlString(urlString: comment.profile_photo, isFullUrl: true)
        senderUsername.text = comment.username
        self.label.text = comment.comment
        
        if comment.ownerId == USER.id {
            deleteButton.visibility = .visible
            addButton.visibility = .gone
            optionsButton.visibility = .gone

        } else {
            deleteButton.visibility = .gone
            addButton.visibility = .visible
        }
        
        if comment.isMaxLength > 0 {
            stackView.visibility = .gone
            continueConversationButton.visibility = .gone
            moreCommentsButton.visibility = .visible
            moreCommentsButton.setTitle("\(comment.isMaxLength) more comments...", for: .normal)
        } else if comment.isMaxDepth {
            stackView.visibility = .gone
            continueConversationButton.visibility = .visible
            moreCommentsButton.visibility = .gone
        } else {
            stackView.visibility = .visible
            continueConversationButton.visibility = .gone
            moreCommentsButton.visibility = .gone
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
