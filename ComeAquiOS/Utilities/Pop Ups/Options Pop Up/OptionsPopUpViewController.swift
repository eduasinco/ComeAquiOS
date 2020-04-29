//
//  OptionsPopUpViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 28/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//
import UIKit
protocol OptionsPopUpProtocol {
    func optionPressed(_ title: String)
}

class OptionsPopUpViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    
    var delegate: OptionsPopUpProtocol?
    var options: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let options = self.options else {return}
        for option in options {
            let button = createButton(option)
            stackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func buttonPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        delegate?.optionPressed(sender.titleLabel!.text!)
    }
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func createButton(_ title: String, _ color: UIColor = UIColor.black) -> UIButton{
        let button = UIButton()
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitleColor(color, for: .normal)
        button.setTitle(title, for: .normal)
        return button
    }
    
}
