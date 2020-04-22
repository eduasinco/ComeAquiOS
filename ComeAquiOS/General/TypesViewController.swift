//
//  TypesViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//
import UIKit

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
    var toInteract = true
    var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        buttons = []
        
        for string in toInteract ? images : filledImages {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(named: string), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.clipsToBounds = true
            if toInteract {
                button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
            }
            buttons.append(button)
        }
        
        for type in buttons {
            let constraint = type.widthAnchor.constraint(equalToConstant: 12)
            constraint.isActive = true
            stackView.addArrangedSubview(type)
        }
    }
    
    @objc func buttonClicked(sender: AnyObject?) {
        if sender === buttons[0] {
            buttonsClicked[0] = !buttonsClicked[0]
            buttons[0].setImage(UIImage(named: buttonsClicked[0] ? filledImages[0] : images[0]), for: .normal)
        } else if sender === buttons[1] {
            buttonsClicked[1] = !buttonsClicked[1]
        } else if sender === buttons[2] {
            buttonsClicked[2] = !buttonsClicked[2]
        } else if sender === buttons[3] {
            buttonsClicked[3] = !buttonsClicked[3]
        } else if sender === buttons[4] {
            buttonsClicked[4] = !buttonsClicked[4]
        } else if sender === buttons[5] {
            buttonsClicked[5] = !buttonsClicked[5]
        } else if sender === buttons[6] {
            buttonsClicked[6] = !buttonsClicked[6]
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

}
