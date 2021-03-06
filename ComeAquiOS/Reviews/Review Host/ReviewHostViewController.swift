//
//  ReviewHostViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 14/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

private class ResponseObject: Decodable {
    var error_message: String?
    var data: [PaymentMethodObject]?
}
class ReviewHostViewController: KUIViewController {
    
    @IBOutlet weak var profileImage: URLImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var posterRating: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var tipButtonStack: UIStackView!
    @IBOutlet weak var noTipButton: UIButton!
    @IBOutlet weak var tip15Button: UIButton!
    @IBOutlet weak var tip20Button: UIButton!
    @IBOutlet weak var tip25Button: UIButton!
    @IBOutlet weak var paymentMethodText: UILabel!
    @IBOutlet weak var amountField: CurrencyTextField!
    @IBOutlet weak var starReasonView: UIStackView!
    @IBOutlet weak var reviewText: UITextView!
    @IBOutlet weak var wordCountText: UILabel!
    @IBOutlet weak var submitButton: LoadingButton!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    var order: OrderObject?
    var paymentMethod: PaymentMethodObject?
    var price: Int?
    var rating: Int?
    var reasons: [Bool]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getChosenCard()
        self.bottomConstraintForKeyboard = bottomViewConstraint
        amountField.addTarget(self, action: #selector(myTextFieldBegin), for: .editingChanged)
        reviewText.delegate = self
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
    }
    func setView() {
        guard let order = self.order else {return}
        profileImage.loadImageUsingUrlString(urlString: order.poster?.profile_photo_)
        posterName.text = order.poster?.full_name
        posterRating.text = "\(order.poster!.rating!)"
        totalAmount.text = "\(order.order_price!.format())"
        starReasonView.visibility = .goneY
        amountField.isEnabled = false
        
        
        guard let payment = self.paymentMethod else {return}
        paymentMethodText.text = payment.last4
    }
    @objc func myTextFieldBegin(_ textField: UITextField) {
        price = Int(amountField.enteredNumbers) ?? 0
        starReasonView.visibility = .visible
    }
    
    @IBAction func noTip(_ sender: Any) {
        price = 0
        tipClicked(button: noTipButton)
    }
    @IBAction func tip15(_ sender: Any) {
        price = Int(Float(order!.order_price!) * Float(15) / Float(100))
        tipClicked(button: tip15Button)
    }
    @IBAction func tip20(_ sender: Any) {
        price = Int(Float(order!.order_price!) * Float(20) / Float(100))
        tipClicked(button: tip20Button)
    }
    @IBAction func tip25(_ sender: Any) {
        price = Int(Float(order!.order_price!) * Float(25) / Float(100))
        tipClicked(button: tip25Button)
    }
    @IBAction func submit(_ sender: Any) {
        postReview()
    }
    
    var customTip = false
    @IBAction func customTip(_ sender: Any) {
        customTip = !customTip
        UIView.animate(withDuration: 0.5) {
            self.tipButtonStack.visibility = self.customTip ? .gone : .visible
            self.amountField.isEnabled = self.customTip ? true : false
            if self.customTip {
                self.amountField.becomeFirstResponder()
            }
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func changePayment(_ sender: Any) {
        performSegue(withIdentifier: "ChangePaymentSegue", sender: nil)
    }
    
    func tipClicked(button: UIButton){
        amountField.text = "$ " + price!.format()
        for b in [noTipButton, tip15Button, tip20Button, tip25Button] {
            if b == button {
                b?.backgroundColor = UIColor(named: "PrimaryLight")
                b?.setTitleColor(UIColor.white, for: .normal)
            } else {
                b?.backgroundColor = UIColor.white
                b?.setTitleColor(UIColor(named: "PrimaryLight"), for: .normal)
            }
        }
        starReasonView.visibility = .visible
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangePaymentSegue" {
            let vc = segue.destination as? AddPaymentMethodViewController
            vc?.isChangeMode = true
        } else if segue.identifier == "StarReasonSegue" {
            let vc = segue.destination as? StartReasonViewController
            vc?.delegate = self
        }
    }
}
extension ReviewHostViewController: StarReasonDelegate {
    func rating(_ rate: Int) {
        self.rating = rate
        submitButton.isEnabled = true
        submitButton.alpha = 1
    }
    
    func reasons(reasons: [Bool]?) {
        self.reasons = reasons
    }
}

extension ReviewHostViewController {
    func getChosenCard(){
        presentTransparentLoader()
        Server.get("/my_chosen_card/"){ data, response, error in
            DispatchQueue.main.async {
                self.closeTransparentLoader()
            }
            if let _ = error {
                self.onReload = self.getChosenCard
            }
            guard let data = data else {return}
            do {
                let responseO = try JSONDecoder().decode(ResponseObject.self, from: data)
                if responseO.error_message == nil {
                    if let data = responseO.data, data.count > 0 {
                        self.paymentMethod = data[0]
                    }
                    DispatchQueue.main.async {
                        self.setView()
                    }
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        }
    }
    
    func postReview(){
        submitButton.showLoading()
        Server.post("/create_review/",
                    json:
            ["order_id":  order?.id,
             "review":  reviewText.text,
             "rating":  rating,
             "star_reason": "",
             "tip":  price,]) { data, response, error in
                if let _ = error {
                    self.view.showToast(message: "No internet connection")
                }
                DispatchQueue.main.async {
                    self.submitButton.hideLoading()
                }
                guard let data = data else {
                    return
                }
                do {
                    let review = try JSONDecoder().decode(ReviewObject.self, from: data)
                    guard review.id != nil else {return}
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                } catch _ {
                    self.view.showToast(message: "Some error ocurred")
                }
        }
    }
}

extension ReviewHostViewController: UITextViewDelegate, UITextFieldDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        wordCountText.text = "\(numberOfChars)/202"
        return numberOfChars < 202    // 10 Limit Value
    }
}
