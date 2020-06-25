//
//  AreYouSureViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 25/06/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol AreYouSureDelegate{
    func goAhead()
}

class AreYouSureViewController: UIViewController {

    @IBOutlet weak var card: UIView!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var titleString: String?
    var messageString: String?
    var actionButtonTitle: String?
    var cancelButtonTitle: String?
    
    var delegate: AreYouSureDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertTitle.text = titleString
        message.text = messageString
        actionButton.setTitle(actionButtonTitle, for: .normal)
        cancelButton.setTitle(cancelButtonTitle ?? "Cancel", for: .normal)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.goAhead()
    }
}
