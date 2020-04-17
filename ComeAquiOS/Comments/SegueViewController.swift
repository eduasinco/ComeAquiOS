//
//  SegueViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 16/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class SegueViewController: UIViewController, UIScrollViewDelegate {

    var commentId: Int?
    var max_depth = 0
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelfSegue"{
            let destVC = segue.destination as! CommentsViewController
            destVC.commentId = self.commentId
            destVC.max_depth = self.max_depth
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
