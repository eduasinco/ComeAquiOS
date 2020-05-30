//
//  TypesViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//
import UIKit
protocol TypesProtocol{
    func typeChanged(types: String)
}
class TypesViewController: UIViewController {
    var stackView : UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 4
        sv.distribution = .fillEqually
        return sv
    }()
    
    let filledImages = ["vegetarian_fill", "vegan_fill", "wheat_fill", "spyci_fill", "fish_fill", "meat_fill", "diary_fill"]
    let images = ["vegetarian", "vegan", "wheat", "spyci", "fish", "meat", "diary"]
    var buttonsClicked = [false, false, false, false, false, false, false]
    var buttons: [UIButton]!
    
    var delegate: TypesProtocol?
    var initialTypesString: String? {
        didSet {
        }
    }
    
    func setTypes(typeString: String){
        for (i, c) in typeString.enumerated(){
            if c == "1" {
                buttons[i].visibility = .visible
            } else if c == "0"{
                buttons[i].visibility = .gone
            }
        }
        view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        setView()
    }
    
    func setView(){
        buttons = []
        if let initalTypesString = self.initialTypesString {
            for i in 0..<initalTypesString.count {
                let button = UIButton()
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setImage(UIImage(named: initalTypesString.charAt(i) == "1" ? filledImages[i] : images[i]), for: .normal)
                buttonsClicked[i] = initalTypesString.charAt(i) == "1" ? true : false
                button.imageView?.contentMode = .scaleAspectFit
                button.clipsToBounds = true
                button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
                buttons.append(button)
            }
        } else {
            for string in filledImages {
                let button = UIButton()
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setImage(UIImage(named: string), for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
                button.clipsToBounds = true
                buttons.append(button)
            }
        }
        
        for type in buttons {
            let constraint = type.widthAnchor.constraint(equalToConstant: 12)
            constraint.isActive = true
            stackView.addArrangedSubview(type)
        }
    }
    
    @objc func buttonClicked(sender: AnyObject?) {
        if sender === buttons[0] {
            changeButtonImage(0)
        } else if sender === buttons[1] {
            changeButtonImage(1)
        } else if sender === buttons[2] {
            changeButtonImage(2)
        } else if sender === buttons[3] {
            changeButtonImage(3)
        } else if sender === buttons[4] {
            changeButtonImage(4)
        } else if sender === buttons[5] {
            changeButtonImage(5)
        } else if sender === buttons[6] {
            changeButtonImage(6)
        }
    }
    func changeButtonImage(_ index: Int){
        buttonsClicked[index] = !buttonsClicked[index]
        buttons[index].setImage(UIImage(named: buttonsClicked[index] ? filledImages[index] : images[index]), for: .normal)
        
        var stringType = ""
        for b in buttonsClicked{
            if b {
                stringType += "1"
            } else {
                stringType += "0"
            }
        }
        delegate?.typeChanged(types: stringType)
    }
}
