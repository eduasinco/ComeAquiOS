//
//  StartReasonViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol StarReasonDelegate {
    func rating(_ rate: Int)
    func reasons(reasons: [Bool]?)
}

class StartReasonViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var star0: UIButton!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var rageMessage: UILabel!
    @IBOutlet weak var infoMessage: UILabel!
    @IBOutlet weak var reason0: UIButton!
    @IBOutlet weak var reason1: UIButton!
    @IBOutlet weak var reason2: UIButton!
    @IBOutlet weak var reason3: UIButton!
    
    var rating: Int?
    var delegate: StarReasonDelegate?
    var starArray: [UIButton]!
    var reasons: [UIButton]!
    var reasonsB = [false, false, false, false]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        stackView.visibility = .gone
        starArray = [star0, star1, star2, star3, star4]
        reasons = [reason0, reason1, reason2,reason3]
    }
    @IBAction func star0(_ sender: Any) {
        onStarClick(0)
    }
    @IBAction func star1(_ sender: Any) {
        onStarClick(1)
    }
    @IBAction func star2(_ sender: Any) {
        onStarClick(2)
    }
    @IBAction func star3(_ sender: Any) {
        onStarClick(3)
    }
    @IBAction func star4(_ sender: Any) {
        onStarClick(4)
    }
    
    func onStarClick(_ i: Int) {
        rating = i + 1
        delegate?.rating(rating!)
        stackView.visibility = .visible
        var j = 0
        while j <= i {
            starArray[j].setImage(UIImage(systemName: "star.fill"), for: .normal)
            j += 1
        }
        while j < starArray.count {
            starArray[j].setImage(UIImage(systemName: "star"), for: .normal)
            j += 1
        }
        if (i == 4){
            changeReasonText(true, i)
        } else {
            changeReasonText(false, i)
        }
    }

    func changeReasonText(_ good: Bool, _ i: Int){
        let rateMessage = ["AWFUL", "BAD", "INDIFFERENT", "COULD BE BETTER", "GREAT"]
        if (good){
            rageMessage.text = rateMessage[i]
            infoMessage.text = "Great! What did you like the most?"
            reason0.setTitle("More than better", for: .normal)
            reason1.setTitle("She/he was nice", for: .normal)
            reason2.setTitle("Clean house", for: .normal)
            reason3.setTitle("Good conversation", for: .normal)
        } else {
            rageMessage.text = rateMessage[i]
            infoMessage.text = "We regret hearing that. What was the issue?"
            reason0.setTitle("Problem with host", for: .normal)
            reason1.setTitle("Problem with food", for: .normal)
            reason2.setTitle("Problem with cleaning", for: .normal)
            reason3.setTitle("Problem with payment", for: .normal)
        }
    }
    
    @IBAction func reason0(_ sender: Any) {
        reasonClicked(0)
    }
    @IBAction func reason1(_ sender: Any) {
        reasonClicked(1)
    }
    @IBAction func reason2(_ sender: Any) {
        reasonClicked(2)
    }
    @IBAction func reason3(_ sender: Any) {
        reasonClicked(03)
    }
    
    func reasonClicked(_ i: Int){
        let reason = reasons[i]
        reasonsB[i] = !reasonsB[i]
        delegate?.reasons(reasons: reasonsB)
        if (reasonsB[i]){
            reason.backgroundColor = UIColor.black
            reason.setTitleColor(UIColor.white, for: .normal)
        } else {
            reason.backgroundColor = UIColor.white
            reason.setTitleColor(UIColor.black, for: .normal)
        }
    }
}
