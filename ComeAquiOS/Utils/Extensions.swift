//
//  Extensions.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

extension UIView {
    @discardableResult
    public func roundCorners(radius: CGFloat, clip: Bool = false) -> UIView{
        self.layer.cornerRadius = radius
        self.clipsToBounds = clip
        return self
    }
    
    @discardableResult
    public func circle() -> UIView{
        self.layer.cornerRadius = min(self.frame.height, self.frame.width) / 2
        self.clipsToBounds = true
        return self
    }
    
    @discardableResult
    public func dropShadow(radius: CGFloat = 0, opacity: Float = 0) -> UIView{
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = radius
        return self
    }
    
    @discardableResult
    public func border(witdth: CGFloat = 5, color: CGColor = UIColor.black.cgColor) -> UIView{
        self.layer.borderWidth = witdth
        self.layer.borderColor = color
        return self
    }
    
    @discardableResult
    public func textFieldBorderStyle() -> UIView{
        self.border(witdth: 1, color: UIColor.white.cgColor).roundCorners(radius: 4)
        self.clipsToBounds = true
        return self
    }
    
    func findConstraint(layoutAttribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        if let constraints = superview?.constraints {
            for constraint in constraints where itemMatch(constraint: constraint, layoutAttribute: layoutAttribute) {
                return constraint
            }
        }
        return nil
    }

    func itemMatch(constraint: NSLayoutConstraint, layoutAttribute: NSLayoutConstraint.Attribute) -> Bool {
        let firstItemMatch = constraint.firstItem as? UIView == self && constraint.firstAttribute == layoutAttribute
        let secondItemMatch = constraint.secondItem as? UIView == self && constraint.secondAttribute == layoutAttribute
        return firstItemMatch || secondItemMatch
    }
}

extension UIScrollView {

    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }

    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }

    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }

    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}


extension UIView {

    // MARK: visibility methods

    public enum Visibility : Int {
        case visible = 0
        case invisible = 1
        case gone = 2
        case goneY = 3
        case goneX = 4
    }

    public var visibility: Visibility {
        set {
            switch newValue {
                case .visible:
                    isHidden = false
                    getConstraintY(false)?.isActive = false
                    getConstraintX(false)?.isActive = false
                case .invisible:
                    isHidden = true
                    getConstraintY(false)?.isActive = false
                    getConstraintX(false)?.isActive = false
                case .gone:
                    isHidden = true
                    getConstraintY(true)?.isActive = true
                    getConstraintX(true)?.isActive = true
                case .goneY:
                    isHidden = true
                    getConstraintY(true)?.isActive = true
                    getConstraintX(false)?.isActive = false
                case .goneX:
                    isHidden = true
                    getConstraintY(false)?.isActive = false
                    getConstraintX(true)?.isActive = true
            }
        }
        get {
            if isHidden == false {
                return .visible
            }
            if getConstraintY(false)?.isActive == true && getConstraintX(false)?.isActive == true {
                return .gone
            }
            if getConstraintY(false)?.isActive == true {
                return .goneY
            }
            if getConstraintX(false)?.isActive == true {
                return .goneX
            }
            return .invisible
        }
    }

    fileprivate func getConstraintY(_ createIfNotExists: Bool = false) -> NSLayoutConstraint? {
        return getConstraint(.height, createIfNotExists)
    }

    fileprivate func getConstraintX(_ createIfNotExists: Bool = false) -> NSLayoutConstraint? {
        return getConstraint(.width, createIfNotExists)
    }

    fileprivate func getConstraint(_ attribute: NSLayoutConstraint.Attribute, _ createIfNotExists: Bool = false) -> NSLayoutConstraint? {
        let identifier = "random_id"
        var result: NSLayoutConstraint? = nil
        for constraint in constraints {
            if constraint.identifier == identifier {
                result = constraint
                break
            }
        }
        if result == nil && createIfNotExists {
            // create and add the constraint
            result = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 0)
            result?.identifier = identifier
            addConstraint(result!)
        }
        return result
    }
}



extension String {

    // formatting text for currency textField
    func currencyInputFormatting() -> String {

        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        var amountWithPrefix = self

        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")

        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))

        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }

        return formatter.string(from: number)!
    }
    func stringAt(_ i: Int) -> String {
      return String(Array(self)[i])
    }

    func charAt(_ i: Int) -> Character {
     return Array(self)[i]
    }
}


extension Int {
    func format(_ f: Int = 2) -> String {
        let f = Float(self / 100)
        return f.format()
    }
}

extension Double {
    func format(f: Int = 2) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension Float {
    func format(_ f: Int = 2) -> String {
        return String(format: "%.\(f)f", self)
    }
}
