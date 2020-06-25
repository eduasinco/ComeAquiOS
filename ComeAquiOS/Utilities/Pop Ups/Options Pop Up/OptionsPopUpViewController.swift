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
    
    var actionText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomCardBehaviour(view: cardView, backGround: self.view, onHide: {() -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        guard let options = self.options else {return}
        for (i, option) in options.enumerated() {
            let button = createButton(option, (option.contains("Cancel") || option.contains("Delete") || option.contains("Report")) ? UIColor(named: "Canceledd")!: UIColor(named: "Primary")!)
            stackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
            if let images = images, let image = images[i] {
                button.setImage(image, for: .normal)
            }
        }
    }
    
    @objc func buttonPressed(sender: UIButton) {
        self.actionText = sender.titleLabel!.text!
        if (self.actionText.contains("Delete") || self.actionText.contains("Cancel") || self.actionText.contains("Report")){
            self.performSegue(withIdentifier: "AreYouSureSegue", sender: nil)
        } else {
            moveCardOut(view: cardView, onFinish: {() -> Void in
                self.dismiss(animated: true, completion: nil)
                self.delegate?.optionPressed(self.actionText)
            })
        }
    }
    @IBAction func cancelPressed(_ sender: Any) {
        moveCardOut(view: cardView, onFinish: {() -> Void in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func createButton(_ title: String, _ color: UIColor = UIColor(named: "Primary")!) -> UIButton{
        let button = UIButton()
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitleColor(color, for: .normal)
        button.setTitle(title, for: .normal)
        return button
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AreYouSureSegue" {
            let vc = segue.destination as? AreYouSureViewController
            let action = self.actionText.lowercased().trimmingCharacters(in: .whitespaces)
            vc?.delegate = self
            vc?.titleString = "Are you sure you want to " + action + "?"
            vc?.messageString = "This action may result in irreversible changes, make sure you want to " + action + " before continuing"
            vc?.actionButtonTitle = self.actionText
        }
    }
}

extension OptionsPopUpViewController: AreYouSureDelegate {
    func goAhead() {
        moveCardOut(view: cardView, onFinish: {() -> Void in
            self.dismiss(animated: true, completion: nil)
            self.delegate?.optionPressed(self.actionText)
        })
    }
}
