//
//  Classes.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

final class CardView: UIView {
    private var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0, height: 1.0)
            shadowLayer.shadowOpacity = 0.4
            shadowLayer.shadowRadius = 1

            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }
}

class URLImageView: UIImageView {
    public func loadImageUsingUrlString(urlString: String) {
        let url = NSURL(string: SERVER + urlString)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, respones, error) in
            if error != nil {
                print(error ?? "Errooooor")
                return
            }
            DispatchQueue.main.async{
                let image = UIImage(data: data!)
                self.image = image
            }
        }).resume()
    }
}

private let imageCache = NSCache<NSString, UIImage>()
class CellImageView: UIImageView {
    var imageUrlString: String?
    
    public func loadImageUsingUrlString(urlString: String) {
        imageUrlString = urlString
        let url = NSURL(string: urlString)
        
        image = nil
        if let imageFromCache = imageCache.object(forKey: NSString(string: urlString)) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, respones, error) in
            if error != nil {
                print(error ?? "Errooooor")
                return
            }
            DispatchQueue.main.async{
                let imageToCache = UIImage(data: data!)
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                imageCache.setObject(imageToCache!, forKey:  NSString(string: urlString))
            }
        }).resume()
    }
}

class ContentWrappingTableView: UITableView {

  override var intrinsicContentSize: CGSize {
    return self.contentSize
  }

  override var contentSize: CGSize {
    didSet {
        self.invalidateIntrinsicContentSize()
    }
  }
}


class KUIViewController: UIViewController {

    // KBaseVC is the KEYBOARD variant BaseVC. more on this later

    @IBOutlet var bottomConstraintForKeyboard: NSLayoutConstraint!

    @objc func keyboardWillShow(sender: NSNotification) {
        let i = sender.userInfo!
        let k = (i[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        bottomConstraintForKeyboard.constant = k - bottomLayoutGuide.length
        let s: TimeInterval = (i[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let s: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraintForKeyboard.constant = 0
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

class MyOwnTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }

    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}

class CurrencyTextField: UITextField {

    /// The numbers that have been entered in the text field
    var enteredNumbers = ""

    private var didBackspace = false

    var locale: Locale =  Locale(identifier: "en_US_POSIX")

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    override func deleteBackward() {
        enteredNumbers = String(enteredNumbers.dropLast())
        text = enteredNumbers.asCurrency(locale: locale)
        // Call super so that the .editingChanged event gets fired, but we need to handle it differently, so we set the `didBackspace` flag first
        didBackspace = true
        super.deleteBackward()
    }

    @objc func editingChanged() {
        defer {
            didBackspace = false
            text = enteredNumbers.asCurrency(locale: locale)
        }
        
        guard Int(enteredNumbers) ?? 0 <= 99999999 else { return }
        guard didBackspace == false else { return }

        if let lastEnteredCharacter = text?.last, lastEnteredCharacter.isNumber {
            enteredNumbers.append(lastEnteredCharacter)
        }
    }
}

private extension Formatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
}

private extension String {
    func asCurrency(locale: Locale) -> String? {
        Formatter.currency.locale = locale
        if self.isEmpty {
            return Formatter.currency.string(from: NSNumber(value: 0))
        } else {
            return Formatter.currency.string(from: NSNumber(value: (Double(self) ?? 0) / 100))
        }
    }
}
