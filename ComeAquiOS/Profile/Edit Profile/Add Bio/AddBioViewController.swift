//
//  AddBioViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 10/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class AddBioViewController: KUIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var wordCountText: UILabel!
    @IBOutlet weak var bcfkb: NSLayoutConstraint!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        self.bottomConstraintForKeyboard = bcfkb
        getUser()
    }
    func setView(){
        guard let user = self.user else {return}
        textView.text = user.bio
    }
    @IBAction func submit(_ sender: Any) {
        addBio()
    }
}

extension AddBioViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        wordCountText.text = "\(numberOfChars)/202"
        return numberOfChars < 202
    }
}

extension AddBioViewController{
    func getUser(){
        Server.get("/profile_detail/\(USER._id!)/"){ data, response, error in
            DispatchQueue.main.async {
                
            }
            guard let data = data else {
                return
            }
            do {
                self.user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.setView()
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        }
    }
    func addBio(){
        
        Server.patch("/edit_profile/",
                    json:
            ["bio": textView.text]) { data, response, error in
            if let _ = error {
                self.view.showToast(message: "No internet connection")
            }
                        guard data != nil else {
                            return
                        }
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
        }
    }
}
