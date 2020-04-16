//
//  TypesViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//
import UIKit

class TypesViewController: UIViewController {

//    var stackView: UIStackView = {
//        let sv = UIStackView()
//        sv.translatesAutoresizingMaskIntoConstraints = false
//        return sv
//    }()
    
    
    @IBOutlet weak var stackView: UIStackView!
    var types : [UIImageView] = {
        let imageStrings = ["vegetarian_fill", "vegan_fill", "wheat_fill", "spyci_fill", "fish_fill", "meat_fill", "diary_fill"]
        var types : [UIImageView] = []
        for string in imageStrings {
            let iv = UIImageView()
            iv.image = UIImage(named: string)
            iv.contentMode = .scaleAspectFit
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            types.append(iv)
        }
        return types
    }()
    var widthConstraints : [NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        for type in types {
            let constraint = type.widthAnchor.constraint(equalToConstant: 12)
            constraint.isActive = true
            widthConstraints.append(constraint)
            stackView.addArrangedSubview(type)
        }
    }
    
    func setTypes(typeString: String){
        for (i, c) in typeString.enumerated(){
            if c == "1" {
                types[i].isHidden = false
                widthConstraints[i].constant = 12
            } else if c == "0"{
                print(i)
                types[i].isHidden = true
                widthConstraints[i].constant = 0
            }
        }
        view.layoutIfNeeded()
    }

}
