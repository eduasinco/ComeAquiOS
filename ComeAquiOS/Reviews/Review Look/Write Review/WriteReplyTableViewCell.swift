//
//  WriteReplyTableViewCell.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 30/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol WriteReplyProtocol {
    func replyAdded(reply: ReviewReplyObject)
}

class WriteReplyTableViewCell: KUIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet weak var usernameAndDate: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submitButton: LoadingButton!
    @IBOutlet weak var bcfkb: NSLayoutConstraint!
    
    var review: ReviewObject?
    var originalHeight: CGFloat!
    
    var delegate: WriteReplyProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.isScrollEnabled = false
        originalHeight = self.view.frame.height
        self.bottomConstraintForKeyboard = bcfkb
        
        reviewText.text = review?.review
        usernameAndDate.text = review!.owner!.username! + " " + review!.created_at_to_show!
        submitButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (submitPress)))
    }
    
    @objc func submitPress() {
        postReply()
    }
}
extension WriteReplyTableViewCell{
    func postReply(){
        submitButton.showLoading()
        Server.post("/create_review_reply/",
                    json:
            [
                "reply": textView.text,
                "review_id": review?.id,
        ]) { data, response, error in
            DispatchQueue.main.async {
                self.submitButton.hideLoading()
            }
            if let _ = error {
                self.view.showToast(message: "No internet connection")
            }
            guard let data = data else {return}
            do {
                let reply = try JSONDecoder().decode(ReviewReplyObject.self, from: data)
                DispatchQueue.main.async {
                    self.delegate?.replyAdded(reply: reply)
                    self.dismiss(animated: true, completion: nil)
                }
            } catch {}
        }
    }
}

extension WriteReplyTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
}


