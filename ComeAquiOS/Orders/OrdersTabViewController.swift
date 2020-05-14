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
    
    var page: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        width.constant = self.view.frame.width
        scrollView.delegate = self
        // scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func guestingPressed(_ sender: Any) {
        changePage(0)
    }
    @IBAction func hostingPressed(_ sender: Any) {
        changePage(1)

    }
    func changePage(_ index: Int){
        let x = index * Int(scrollView.frame.width)
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        pageControl.currentPage = index
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        pageControl.currentPage = page
    }
}
