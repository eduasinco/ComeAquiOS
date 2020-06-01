//
//  Extensions.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import MapKit

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
    public func dropShadow(radius: CGFloat = 0, opacity: Float = 0, height: Int = 0) -> UIView{
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: 0, height: height)
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
        self.border(witdth: 1, color: UIColor(named: "Primary")!.cgColor).roundCorners(radius: 4)
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
extension UIView {
    @IBInspectable var isRounded: Bool {
        set {
            if newValue {
                self.layer.masksToBounds = false
                self.layer.cornerRadius = self.frame.height / 2
                self.clipsToBounds = true
            }
        }
        get {
            return false
        }
    }
    
    @IBInspectable var strikeColor: UIColor  {
        set {
            self.layer.borderColor = newValue.cgColor
        }
        get{
            return UIColor.clear
        }
    }
    @IBInspectable var strike: Int {
        set {
            self.layer.borderWidth = CGFloat(newValue)
            self.layer.borderColor = UIColor.black.cgColor
        }
        get {
            return 0
        }
    }
    @IBInspectable var roudCorners: Int {
        set {
            self.roundCorners(radius: CGFloat(newValue), clip: false)
        }
        get {
            return 0
        }
    }
    
    func changeColor(newValue: Int) {
        switch newValue {
        case 1:
            self.backgroundColor = UIColor.orange
        case 2:
            self.backgroundColor = UIColor.lightGray
        case 3:
            self.backgroundColor = UIColor.orange
        case 4:
            self.backgroundColor = UIColor.lightGray
        default:
            break
        }
    }
    
    @IBInspectable var appBackgroundColor: Int {
        set {
            changeColor(newValue: newValue)
        }
        get {
            return 0
        }
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

extension UITextField {
    func placeholderColor(_ color: UIColor){
        let color = color
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : color])
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
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    func isValidUsername() -> Bool {
        let emailRegEx = "[A-Za-z0-9_]+"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    func isValidPassword() -> Bool {
        let emailRegEx = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=\\S+$).{8,}$"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}

extension Int {
    func format(_ f: Int = 2) -> String {
        let f = Float(self) / 100
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

extension UITableView {
    func showActivityIndicator() {
        DispatchQueue.main.async {
            let activityView = UIActivityIndicatorView(style: .medium)
            self.backgroundView = activityView
            activityView.startAnimating()
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.backgroundView = nil
        }
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
}

extension CLLocation {
    func movedBy(latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) -> CLLocation {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: abs(latitudinalMeters), longitudinalMeters: abs(longitudinalMeters))

        let latitudeDelta = region.span.latitudeDelta
        let longitudeDelta = region.span.longitudeDelta

        let latitudialSign = CLLocationDistance(latitudinalMeters.sign == .minus ? -1 : 1)
        let longitudialSign = CLLocationDistance(longitudinalMeters.sign == .minus ? -1 : 1)

        let newLatitude = coordinate.latitude + latitudialSign * latitudeDelta
        let newLongitude = coordinate.longitude + longitudialSign * longitudeDelta

        let newCoordinate = CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)

        let newLocation = CLLocation(coordinate: newCoordinate, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: Date())

        return newLocation
    }
}

extension UIColor {
    static func colorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
