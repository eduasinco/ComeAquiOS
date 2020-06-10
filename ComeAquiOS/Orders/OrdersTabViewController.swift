//
//  OrdersTabViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 29/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class OrdersTabViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var guestingButton: UIButton!
    @IBOutlet weak var hostingButton: UIButton!
    
    var page: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        width.constant = self.view.frame.width
        scrollView.delegate = self
    }
    
    @IBAction func guestingPressed(_ sender: Any) {
        changePage(0)
    }
    @IBAction func hostingPressed(_ sender: Any) {
        changePage(1)

    }
    func changePage(_ index: Int){
        changeButtons(index)
        let x = index * Int(scrollView.frame.width)
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        pageControl.currentPage = index
    }
    
    func changeButtons(_ index: Int){
        if index == 0 {
            guestingButton.setTitleColor(UIColor(named: "SecondaryDark"), for: .normal)
            hostingButton.setTitleColor(UIColor(named: "PrimaryLight"), for: .normal)
        } else if index == 1 {
            guestingButton.setTitleColor(UIColor(named: "PrimaryLight"), for: .normal)
            hostingButton.setTitleColor(UIColor(named: "SecondaryDark"), for: .normal)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        pageControl.currentPage = page
        changeButtons(page)
    }
}
