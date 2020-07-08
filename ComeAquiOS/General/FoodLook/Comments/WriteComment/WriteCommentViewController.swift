//
//  WriteCommentViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol AddCommentDelegate {
    func commentAdded(newComment: Comment)
}

typealias Closure = () -> String

class WriteCommentViewController: KUIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submitButton: LoadingButton!
    @IBOutlet weak var bcfkb: NSLayoutConstraint!
    
    var comment: Comment?
    var foodPost: Comment?
    var originalHeight: CGFloat!
    
    var delegate: AddCommentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.isScrollEnabled = false
        originalHeight = self.view.frame.height
        self.bottomConstraintForKeyboard = bcfkb
        
        commentLabel.text = comment?.comment
        submitButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (submitPress)))
    }
    
    @objc func submitPress() {
        postComment()
    }
}
extension WriteCommentViewController{
    func postComment(){
        submitButton.showLoading()
        var request = getRequestWithAuth("/food_post_comment/\(self.comment!.id!)/")
        var json = [String:Any]()
        json["post_id"] = foodPost?.id ?? nil
        json["comment_id"] = self.comment?.id ?? nil
        json["message"] = textView.text!
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpMethod = "POST"
            request.httpBody = data
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
                // your stuff here
                DispatchQueue.main.async {
                    self.submitButton.showLoading()
                }
                guard let data = data else {
                    return
                }
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                    DispatchQueue.main.async {
                        let newComment = Comment(json: json, parent: self.comment)
                        self.comment?.comments.append(newComment)
                        self.delegate?.commentAdded(newComment: newComment)
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch _ {
                    self.view.showToast(message: "Some error has ocurred")
                }
            })
            task.resume()
        }catch{
        }
    }
}

extension WriteCommentViewController: UITextViewDelegate {
    
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

