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
    @IBOutlet weak var bcfkb: NSLayoutConstraint!
    
    var review: ReviewObject?
    var originalHeight: CGFloat!
    
    var delegate: AddCommentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.isScrollEnabled = false
        originalHeight = self.view.frame.height
        self.bottomConstraintForKeyboard = bcfkb
    }
    
    @IBAction func submitPress(_ sender: Any) {
        postReply()
    }
}
extension WriteReplyTableViewCell{
    func postReply(){
        Server.post("/create_review_reply/",
            json:
            [
                "reply": textView.text,
                "review_id": review?.id,
            ],
            finish: {(data: Data?, response: URLResponse?) in
                guard let data = data else {
                    return
                }
                do {
                    let _ = try JSONDecoder().decode(OrderObject.self, from: data)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                } catch {}
        })
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


