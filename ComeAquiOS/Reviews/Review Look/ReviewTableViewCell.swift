//
//  ReviewTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 30/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol ReviewCellProtocol {
    func reviewOptionsPressed(review: ReviewObject)
    func replyOptionsPressed(reply: ReviewReplyObject)
}

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewerImage: CellImageView!
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var reviewerUsername: UILabel!
    @IBOutlet weak var star0: UIImageView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var reviewMessage: UITextView!
    
    
    @IBOutlet weak var wholeReplyView: UIView!
    @IBOutlet weak var replyerImage: CellImageView!
    @IBOutlet weak var replyerName: UILabel!
    @IBOutlet weak var replyerUsername: UILabel!
    @IBOutlet weak var replyMessage: UITextView!
    
    var delegate: ReviewCellProtocol?
    
    var review: ReviewObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func reviewOptionsPressed(_ sender: Any) {
        guard let review = self.review else {return}
        delegate?.reviewOptionsPressed(review: review)
    }
    @IBAction func replyOptionsPressed(_ sender: Any) {
        guard let review = self.review else {return}
        delegate?.replyOptionsPressed(reply: review.replies![0])
    }
    
    func setCell(review: ReviewObject){
        reviewerImage.loadImageUsingUrlString(urlString: review.owner!.profile_photo!)
        reviewerName.text = review.owner?.full_name
        reviewerUsername.text = review.owner?.username
        reviewMessage.text = review.review
        setStars(review.rating!)
        
        if review.replies!.count > 0 {
            wholeReplyView.visibility = .visible
            let reply = review.replies![0]
            replyerImage.loadImageUsingUrlString(urlString: reply.owner!.profile_photo!)
            replyerName.text = reply.owner?.full_name
            replyerUsername.text = reply.owner?.username
            replyMessage.text = reply.reply
        } else {
            wholeReplyView.visibility = .gone
        }
    }
    func setStars(_ rating: Float){
        let starArray = [star0, star1, star2, star3, star4]
        
        for star in starArray{
            star!.image = UIImage(named: "rate_empty_star")
        }
        
        for i in 0..<Int(rating) {
            starArray[i]?.image = UIImage(named: "rate_fill")
        }
        
        let decimal = rating - floor(rating);
        if (decimal >= 0.75){
            starArray[Int(rating)]!.image = UIImage(named: "rate_fill")
        } else if (decimal >= 0.25) {
            starArray[Int(rating)]!.image = UIImage(named: "rate_half_filled_star")
        }
    }
}
