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

class OptionsPopUpViewController: CardBehaviourViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var cardView: UIView!
    var delegate: OptionsPopUpProtocol?
    var options: [String]?
    var images: [UIImage?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomCardBehaviour(view: cardView, backGround: self.view, onHide: {() -> Void in })
        guard let options = self.options else {return}
        for (i, option) in options.enumerated() {
            let button = createButton(option)
            stackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
            if let images = images, let image = images[i] {
                button.setImage(image, for: .normal)
            }
        }
    }
    
    @objc func buttonPressed(sender: UIButton) {
        moveCardToBottom(view: cardView, onFinish: {() -> Void in
            self.delegate?.optionPressed(sender.titleLabel!.text!)
        })
    }
    @IBAction func cancelPressed(_ sender: Any) {
        moveCardToBottom(view: cardView, onFinish: {() -> Void in})
    }
    
    func createButton(_ title: String, _ color: UIColor = UIColor.black) -> UIButton{
        let button = UIButton()
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitleColor(color, for: .normal)
        button.setTitle(title, for: .normal)
        return button
    }
}
