//
//  View Controllers.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 12/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class KUIViewController: LoadViewController {

    // KBaseVC is the KEYBOARD variant BaseVC. more on this later

    @IBOutlet var bottomConstraintForKeyboard: NSLayoutConstraint!

    @objc func keyboardWillShow(sender: NSNotification) {
        let i = sender.userInfo!
        let k = (i[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        if #available(iOS 11.0, *) {
            bottomConstraintForKeyboard?.constant = k - view.safeAreaInsets.bottom
        } else {
            bottomConstraintForKeyboard?.constant = k - bottomLayoutGuide.length
        }
        let s: TimeInterval = (i[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let s: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraintForKeyboard?.constant = 0
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }

    @objc func clearKeyboard() {
        view.endEditing(true)
    }

    func keyboardNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardNotifications()
        let t = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(t)
        t.cancelsTouchesInView = false
    }
}

extension UIView {
    func showToast(message: String, delay: TimeInterval = 3) {
        DispatchQueue.main.async {
            let toastContainer = UIView(frame: CGRect())
            toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastContainer.alpha = 0.0
            toastContainer.layer.cornerRadius = 20;
            toastContainer.clipsToBounds  =  true

            let toastLabel = UILabel(frame: CGRect())
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.font.withSize(12.0)
            toastLabel.text = message
            toastLabel.clipsToBounds  =  true
            toastLabel.numberOfLines = 0

            toastContainer.addSubview(toastLabel)
            self.addSubview(toastContainer)

            toastLabel.translatesAutoresizingMaskIntoConstraints = false
            toastContainer.translatesAutoresizingMaskIntoConstraints = false

            let centerX = NSLayoutConstraint(item: toastLabel, attribute: .centerX, relatedBy: .equal, toItem: toastContainer, attribute: .centerXWithinMargins, multiplier: 1, constant: 0)
            let lableBottom = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
            let lableTop = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
            toastContainer.addConstraints([centerX, lableBottom, lableTop])

            let containerCenterX = NSLayoutConstraint(item: toastContainer, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            let containerTrailing = NSLayoutConstraint(item: toastContainer, attribute: .width, relatedBy: .equal, toItem: toastLabel, attribute: .width, multiplier: 1.1, constant: 0)
            let containerBottom = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -15)
            self.addConstraints([containerCenterX,containerTrailing, containerBottom])

            let duration = 0.5
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
                toastContainer.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: duration, delay: delay - 2 * duration , options: .curveEaseOut, animations: {
                    toastContainer.alpha = 0.0
                }, completion: {_ in
                    toastContainer.removeFromSuperview()
                })
            })
        }
    }
}

class CardBehaviourViewController: KUIViewController {
    var viewToMove: UIView!
    var onHide: (() -> Void)?
    var backGRound: UIView?
    var constraint: NSLayoutConstraint!
    var initialConstraintConstant: CGFloat = 0
    
    func addBottomCardBehaviour(view: UIView, backGround: UIView?, onHide: @escaping () -> Void) {
        self.onHide = onHide
        self.viewToMove = view
        self.backGRound = backGround
        self.backGRound?.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        
        self.constraint = getConstraint(view: view, attribute: .bottom)
        guard constraint == self.constraint else {return}
        initialConstraintConstant = constraint.constant
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(sender:)))
        view.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        backGround?.addGestureRecognizer(tap)
    }
    
    func addTopCardBehaviour(view: UIView, constraint: NSLayoutConstraint, onHide: @escaping () -> Void) {
        self.onHide = onHide
        self.viewToMove = view
        
        self.constraint = constraint
        guard constraint == self.constraint else {return}
        initialConstraintConstant = constraint.constant
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleTopPan(sender:)))
        view.addGestureRecognizer(pan)
    }
    
    var originY: CGFloat!
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let cardView = sender.view!
        
        switch sender.state {
        case .began:
            originY = cardView.frame.origin.y
            moveViewWithPan(view: cardView, sender: sender)
        case .changed:
            moveViewWithPan(view: cardView, sender: sender)
        case .ended:
            let move = cardView.frame.origin.y - originY
            print(move)
            if move >= cardView.frame.height / 4 {
                moveCardOut(view: cardView, onFinish: self.onHide!)
            } else {
                returnViewToOrigin(view: cardView)
            }
        default:
            break
        }
    }
    var originYTop: CGFloat!
    @objc func handleTopPan(sender: UIPanGestureRecognizer) {
        let cardView = sender.view!
        
        switch sender.state {
        case .began:
            moveViewWithPanTop(view: cardView, sender: sender)
            originYTop = cardView.frame.origin.y
        case .changed:
            moveViewWithPanTop(view: cardView, sender: sender)
        case .ended:
            let move = originYTop - cardView.frame.origin.y
            if move >= cardView.frame.height / 4 {
                moveCardOut(view: cardView, onFinish: self.onHide!)
            } else {
                returnViewToOrigin(view: cardView)
            }
        default:
            break
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        moveCardOut(view: viewToMove, onFinish: self.onHide!)
    }
    
    func getConstraint(view: UIView, attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        var constraint: NSLayoutConstraint?
        for c in view.constraints {
            if (c.firstAttribute == .bottom) {
                constraint = c
                break
            }
        }
        return constraint
    }
    
    
    func moveViewWithPan(view: UIView, sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        print(translation.y)
        constraint.constant = initialConstraintConstant - max(0, translation.y)
    }
    func moveViewWithPanTop(view: UIView, sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        print(min(0, translation.y))
        constraint.constant = initialConstraintConstant + min(0, translation.y)
    }
    func returnViewToOrigin(view: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            self.constraint.constant = self.initialConstraintConstant
            self.view.layoutIfNeeded()
        })
    }
    func moveCardOut(view: UIView, onFinish: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.backGRound?.alpha = 0
            self.constraint.constant = -(self.initialConstraintConstant + self.viewToMove.frame.height)
            self.view.layoutIfNeeded()
        }, completion: {(Bool) -> Void in
            onFinish()
        })
    }
}
