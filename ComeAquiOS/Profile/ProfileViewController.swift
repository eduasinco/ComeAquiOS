//
//  ProfileViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInset = UIEdgeInsets(top: headerView.frame.height, left: 0, bottom: 0, right: 0)
        scrollView.contentOffset.y = -headerView.frame.height
        headerTopConstraint.constant = -headerView.frame.height
        
        backgroundImage.roundCorners(radius: 8)
        userImage.circle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -100 {
            headerTopConstraint.constant = -headerView.frame.height + 100 + scrollView.contentOffset.y
            headerView.dropShadow(radius: 5, opacity: 5)
        } else {
            headerTopConstraint.constant = -headerView.frame.height
            headerView.dropShadow()
        }
    }
}

