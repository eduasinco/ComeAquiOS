//
//  RateStarViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class RateStarViewController: UIViewController {

    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var ratingNLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setRate(rating: Float, rating_n: Int){
        ratingLabel.text = String(format:"%.2f", rating / 100)
        ratingNLabel.text = String(rating_n)
        
        let starArray = [star1, star2, star3, star4, star5]
        
        for star in starArray{
            star!.image = UIImage(named: "rate_empty_star")
        }
        
        for i in 0..<Int(rating) {
            starArray[i]?.image = UIImage(named: "rate_fill")
        }
        
        let decimal = rating - floor(rating);
        if (decimal >= 0.75){
            starArray[Int(rating)]!.image = UIImage(named: "rate_fill")
        } else if (decimal >= 0.25) {
            starArray[Int(rating)]!.image = UIImage(named: "rate_half_filled_star")
        }

        if (rating == 0){
            ratingLabel.text = "--"
            ratingNLabel.text = "(-)"
        } else {
            ratingLabel.text = String(format:"%.1f", rating)
            ratingNLabel.text = "(" + String(rating_n) + ")"
            
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
