//
//  ValidationTexts.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 24/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//
import UIKit

class CurrencyTextField: ValidatedTextField {

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

    override func editingChanged() {
        super.editingChanged()
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

class ValidationTextField: UIStackView {
    
    var validationTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = UIColor.red
        tv.backgroundColor = nil
        tv.textAlignment = .natural
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.font = UIFont.boldSystemFont(ofSize: 14.0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    var textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    
    @IBInspectable  var validationText: String {
        get {
            return self.validationTextView.text
        }
        set (aNewValue) {
            self.validationTextView.visibility = .visible
            self.validationTextView.text = aNewValue
            self.layoutIfNeeded()
        }
    }
    
    @IBInspectable var placeHolder: String? {
        get {
            return self.textField.placeholder
        }
        set (aNewValue) {
            self.textField.placeholder = aNewValue
        }
    }
    
    @IBInspectable var text: String? {
        get {
            return self.textField.text
        }
        set (aNewValue) {
            self.textField.text = aNewValue
        }
    }
    
    var _textAlig = 0
    @IBInspectable var textAlig: Int {
        get {
            return _textAlig
        }
        set (aNewValue) {
            self.textField.textAlignment = [.left, .center, .right, .justified, .natural][aNewValue]
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        
        self.text = textField.text
        self.validationText = validationTextView.text
        self.validationTextView.visibility = .gone
        self.axis = .vertical
        self.addArrangedSubview(validationTextView)
        self.addArrangedSubview(textField)
        self.textField.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        
        self.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                self.removeConstraint(constraint)
            }
        }
        let height = self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.frame.height)
        height.isActive = true
        height.priority = UILayoutPriority(rawValue: 1000)
    }
    @objc func editingChanged() {
        if self.validationTextView.visibility == .visible{
            self.validationTextView.visibility = .gone
            self.layoutIfNeeded()

        }
    }
    
    @objc func editingDidBegin() {
        if self.validationTextView.visibility == .visible{
            self.validationTextView.visibility = .gone
            self.layoutIfNeeded()
        }
    }
    
    
    func showValidationText(_ show: Bool){
        self.validationTextView.visibility = show ? .visible : .gone
        self.layoutIfNeeded()
    }
}


class ValidationTextView: UIStackView, UITextViewDelegate {
    
    var validationTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = UIColor.red
        tv.backgroundColor = nil
        tv.textAlignment = .natural
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.font = UIFont.boldSystemFont(ofSize: 14.0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    var textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    @IBInspectable var validationText: String {
        get {
            return self.validationTextView.text
        }
        set (aNewValue) {
            self.validationTextView.visibility = .visible
            self.validationTextView.text = aNewValue
            self.layoutIfNeeded()
        }
    }
    
    @IBInspectable var text: String? {
        get {
            return self.textView.text
        }
        set (aNewValue) {
            self.textView.text = aNewValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.textView.delegate = self
        self.text = textView.text
        self.validationText = validationTextView.text
        self.validationTextView.visibility = .gone
        self.axis = .vertical
        self.addArrangedSubview(validationTextView)
        self.addArrangedSubview(textView)
        self.textView.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        
        self.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        let height = self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.frame.height)
        height.isActive = true
        height.priority = UILayoutPriority(rawValue: 1000)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.validationTextView.visibility == .visible{
            self.validationTextView.visibility = .gone
            self.layoutIfNeeded()
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        if self.validationTextView.visibility == .visible{
            self.validationTextView.visibility = .gone
            self.layoutIfNeeded()
        }
    }
    func showValidationText(_ show: Bool){
        self.validationTextView.visibility = show ? .visible : .gone
        self.layoutIfNeeded()
    }
}


class ValidationTextField3: UIStackView {
    
    var validationLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.red
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    var textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    var text: String!
    var validationText: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.text = textField.text
        self.validationText = validationLabel.text
        self.validationLabel.visibility = .gone
        self.axis = .vertical
        self.addArrangedSubview(validationLabel)
        self.addArrangedSubview(textField)
        self.textField.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        let heightAnchor = self.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        heightAnchor.isActive = true
        heightAnchor.priority = UILayoutPriority(rawValue: 1000)
    }
    
    func showValidationText(_ show: Bool){
        self.validationLabel.visibility = show ? .visible : .gone
        self.layoutIfNeeded()
    }
}


class ValidationTextField4: UITextField, UITextViewDelegate, UITextFieldDelegate{
    
    var viewForText: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = UIColor.red
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    var validationLabel: UITextView = {
        let lb = UITextView()
        lb.textColor = UIColor.white
        lb.backgroundColor = nil
        lb.textAlignment = .natural
        lb.isUserInteractionEnabled = false
        lb.font = UIFont.boldSystemFont(ofSize: 14.0)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    var validationText: String {
        get {
            return self.validationLabel.text
        }
        set (aNewValue) {
            if self.placeholder! != "" && self.text! != ""{
                self.textBefore = self.text!
                self.placeHolderBefore = self.placeholder!
            }
            self.text = ""
            self.placeholder = ""
            self.viewForText.visibility = .visible
            self.layoutIfNeeded()
            self.validationLabel.text = aNewValue
        }
    }
    
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
        addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)

        self.addSubview(viewForText)
        placeHolderBefore = self.placeholder ?? ""
        self.validationLabel.isScrollEnabled = false
        self.validationLabel.delegate = self
        self.viewForText.addSubview(validationLabel)
        
        var constrs = [
            self.viewForText.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            self.viewForText.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            self.viewForText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            self.viewForText.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4)
        ]
        // self.viewForText.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        constrs.insert(contentsOf:[
            self.validationLabel.topAnchor.constraint(equalTo: viewForText.topAnchor, constant: 0),
            self.validationLabel.trailingAnchor.constraint(equalTo: viewForText.trailingAnchor, constant: -4),
            self.validationLabel.leadingAnchor.constraint(equalTo: viewForText.leadingAnchor, constant: 4),
            self.validationLabel.bottomAnchor.constraint(equalTo: viewForText.bottomAnchor, constant: 0)
        ], at: 0)
        for cons in constrs {
            cons.priority = UILayoutPriority(rawValue: 1000)
        }
        NSLayoutConstraint.activate(constrs)
        
        self.viewForText.visibility = .gone
        self.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        let height = self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.frame.height)
        height.isActive = true
        height.priority = UILayoutPriority(rawValue: 1000)
    }
    
    @objc func editingChanged() {
        if self.viewForText.visibility == .visible{
            self.text = textBefore
            self.placeholder = placeHolderBefore
            self.viewForText.visibility = .gone
            self.layoutIfNeeded()

        }
    }
    
    @objc func editingDidBegin() {
        if self.viewForText.visibility == .visible{
            self.text = textBefore
            self.placeholder = placeHolderBefore
            self.viewForText.visibility = .gone
            self.layoutIfNeeded()
        }
    }
    
    var textBefore = ""
    var placeHolderBefore = ""
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bringSubviewToFront(self.validationLabel)
        self.viewForText.roundCorners(radius: 5)
    }
    
    func showValidationText(_ show: Bool){
        self.textBefore = self.text!
        self.placeHolderBefore = self.placeholder!
        self.text = ""
        self.placeholder = ""
        self.viewForText.visibility = show ? .visible : .gone
        self.layoutIfNeeded()
    }
}

class ValidationTextView2: UITextView, UITextViewDelegate{
    
    var viewForText: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = UIColor.red
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    var validationLabel: UITextView = {
        let lb = UITextView()
        lb.textColor = UIColor.white
        lb.backgroundColor = nil
        lb.textAlignment = .natural
        lb.isUserInteractionEnabled = false
        lb.isScrollEnabled = false
        lb.font = UIFont.boldSystemFont(ofSize: 14.0)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    var validationText: String {
        get {
            return self.validationLabel.text
        }
        set (aNewValue) {
            if self.text! != ""{
                self.textBefore = self.text!
            }
            self.text = ""
            self.viewForText.visibility = .visible
            self.layoutIfNeeded()
            self.validationLabel.text = aNewValue
        }
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.addSubview(viewForText)
        self.viewForText.addSubview(validationLabel)
        self.viewForText.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 4).isActive = true
        self.viewForText.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -4).isActive = true
        self.viewForText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4).isActive = true
        self.viewForText.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -4).isActive = true

        self.validationLabel.topAnchor.constraint(equalTo: viewForText.topAnchor, constant: 0).isActive = true
        self.validationLabel.trailingAnchor.constraint(equalTo: viewForText.trailingAnchor, constant: -4).isActive = true
        self.validationLabel.leadingAnchor.constraint(equalTo: viewForText.leadingAnchor, constant: 4).isActive = true
        self.validationLabel.bottomAnchor.constraint(equalTo: viewForText.bottomAnchor, constant: 0).isActive = true
        self.viewForText.visibility = .gone
    }
    
    @objc func editingChanged() {
        if self.viewForText.visibility == .visible{
            self.text = textBefore
            self.viewForText.visibility = .gone
            self.layoutIfNeeded()

        }
    }
    
    @objc func editingDidBegin() {
        if self.viewForText.visibility == .visible{
            self.text = textBefore
            self.viewForText.visibility = .gone
            self.superview?.layoutIfNeeded()
        }
    }
    
    var textBefore = ""
    var placeHolderBefore = ""
    override func layoutSubviews() {
        super.layoutSubviews()
        self.superview?.bringSubviewToFront(self.validationLabel)
        self.viewForText.roundCorners(radius: 5)
        self.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        let height = self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.frame.height)
        height.isActive = true
        height.priority = UILayoutPriority(rawValue: 1000)
    }
    
    func showValidationText(_ show: Bool){
        self.textBefore = self.text!
        self.text = ""
        self.viewForText.visibility = show ? .visible : .gone
        self.layoutIfNeeded()
    }
}


class ValidatedTextField: UITextField {
    
    var validationTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.red
        tv.backgroundColor = nil
        tv.textAlignment = .natural
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.font = UIFont.boldSystemFont(ofSize: 14.0)
        return tv
    }()
    
    override var placeholder: String? {
        set {
            guard let newValue = newValue else {return}
            super.placeholder = newValue
        }
        get {
            return super.placeholder
        }
    }
    
    @IBInspectable var validationText : String? {
        set {
            validationTextView.text = newValue
            validationTextView.visibility = .visible
            self.layoutIfNeeded()
        }
        get {
            return validationTextView.text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.setValidationTextStyle()
        self.validationTextView.visibility = .gone
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
    }
    
    func setValidationTextStyle(){
        self.validationTextView.textColor = UIColor.red
        self.validationTextView.font = UIFont.boldSystemFont(ofSize: self.validationTextView.font!.pointSize)
        self.validationTextView.textAlignment = .left
    }
    @objc func editingChanged() {
        if validationTextView.visibility == .visible{
            validationTextView.visibility = .gone
            self.layoutIfNeeded()
        }
    }
    @objc func editingDidBegin() {
        if validationTextView.visibility == .visible{
            validationTextView.visibility = .gone
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var superview = self.superview
        while superview != nil && (!superview!.isKind(of: UIStackView.self) || !((superview as? UIStackView)?.axis == .vertical)){
            superview = superview?.superview
            
        }
        guard let sv = superview as? UIStackView else {
            super.layoutSubviews()
            return
        }
        sv.insertArrangedSubview(self.validationTextView, at: 0)
        sv.layoutIfNeeded()
    }
}

class ValidatedTextView: UITextView, UITextViewDelegate {
    var validationTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.red
        tv.backgroundColor = nil
        tv.textAlignment = .natural
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.font = UIFont.boldSystemFont(ofSize: 14.0)
        return tv
    }()
    
    var textCountView: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.black
        tv.isUserInteractionEnabled = false
        tv.font = tv.font.withSize(13.0)
        return tv
    }()
    var max_characters = 202
    
    @IBInspectable var validationText : String? {
        set {
            validationTextView.text = newValue
            validationTextView.visibility = .visible
            self.layoutIfNeeded()
        }
        get {
            return validationTextView.text
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.setValidationTextStyle()
        self.validationTextView.visibility = .gone
        self.addSubview(textCountView)
        self.bringSubviewToFront(textCountView)
        textCountView.text = "0/\(max_characters)"
    }
    
    func setValidationTextStyle(){
        self.validationTextView.textColor = UIColor.red
        self.validationTextView.font = UIFont.boldSystemFont(ofSize: self.validationTextView.font!.pointSize)
        self.validationTextView.textAlignment = .left
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.validationTextView.visibility == .visible{
            self.validationTextView.visibility = .gone
            self.layoutIfNeeded()
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        if self.validationTextView.visibility == .visible{
            self.validationTextView.visibility = .gone
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.delegate = self
        var superview = self.superview
        while superview != nil && (!superview!.isKind(of: UIStackView.self) && !((superview as? UIStackView)?.axis == .vertical)){
            superview = superview?.superview
            
        }
        guard let sv = superview as? UIStackView else {
            super.layoutSubviews()
            return
        }
        sv.insertArrangedSubview(self.validationTextView, at: 0)
        textCountView.trailingAnchor.constraint(equalTo: sv.trailingAnchor).isActive = true
        textCountView.bottomAnchor.constraint(equalTo: sv.bottomAnchor).isActive = true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        textCountView.text = "\(numberOfChars)/\(max_characters)"
        return numberOfChars < max_characters
    }
}
