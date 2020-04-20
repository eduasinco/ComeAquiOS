//
//  FoodCardViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

protocol CardActionProtocol{
    func changeMarker(foodPost: FoodPostObject, image: UIImage)
    func goToFoodLook()
}

class FoodCardViewController: UIViewController {
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var image1: URLImageView!
    @IBOutlet weak var image1Width: NSLayoutConstraint!
    @IBOutlet weak var image2: URLImageView!
    @IBOutlet weak var image3: URLImageView!
    @IBOutlet weak var userImage: URLImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    @IBOutlet weak var favouriteImageView: UIImageView!
    @IBOutlet weak var plateName: UILabel!
    @IBOutlet weak var mealDescription: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var price: UILabel!
    
    var foodPost: FoodPostObject!
    var typesContainer: TypesViewController!
    var rateContainer: RateStarViewController!
    
    var delegate: CardActionProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        userImage.circle()
        setFavouriteClickListener()
        setFoodLookClickListener()
    }
    
    func setView(foodPost: FoodPostObject) {
        self.foodPost = foodPost
        if let favourite = self.foodPost.favourite  {
            favouriteImageView.image = UIImage(named: favourite ? "favourite_star_fill" : "favourite_star")
        } else {
            favouriteImageView.image = UIImage(named: "favourite_star")
        }
        let imageArray = [image1, image2, image3]
        imageScrollView.visibility = .visible
        if foodPost.images!.count == 0 {
            imageScrollView.visibility = .gone
        } else if foodPost.images!.count == 1 {
            self.image1.loadImageUsingUrlString(urlString: foodPost.images![0].food_photo!)
            image1Width.constant = imageScrollView.frame.width
            image1.visibility = .visible
        } else {
            for (i, image) in foodPost.images!.enumerated(){
                imageArray[i]!.visibility = .visible
                imageArray[i]!.loadImageUsingUrlString(urlString: image.food_photo!)
            }
        }
        var i = foodPost.images!.count
        while i < imageArray.count {
            imageArray[i]!.visibility = .gone
            i += 1
        }
        userImage.loadImageUsingUrlString(urlString: foodPost.owner!.profile_photo!)
        userName.text = foodPost.owner!.full_name!
        userUsername.text = foodPost.owner!.username!
        mealDescription.text = foodPost.description!
        plateName.text = foodPost.plate_name!
        time.text = Date.hhmmHappenedNowTodayYesterdayWeekDay(start: foodPost.start_time!, end: foodPost.end_time!)
        price.text = "$" + String(format:"%.2f", Double(foodPost.price!) / 100)
        typesContainer.setTypes(typeString: foodPost.food_type ?? "0000000")
        rateContainer.setRate(rating: foodPost.owner!.rating!, rating_n: foodPost.owner!.rating_n!)
    }
    
    @objc func tapDetected() {
        setFavourite()
    }
    
    func setFoodLookClickListener(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(goToFoodLook))
        mealDescription.isUserInteractionEnabled = true
        mealDescription.addGestureRecognizer(singleTap)
    }
    @objc func goToFoodLook(){
        delegate?.goToFoodLook()
    }
    
    func setFavouriteClickListener(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        favouriteImageView.isUserInteractionEnabled = true
        favouriteImageView.addGestureRecognizer(singleTap)
    }
    
    func imageWithImage(image:UIImage, width: Int) -> UIImage{
        let proportion = image.size.height / image.size.width
        let height = proportion * CGFloat(width)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: Int(height)), false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: Int(height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypeSegue" {
            typesContainer = segue.destination as? TypesViewController
        } else if segue.identifier == "RateSegue" {
            rateContainer = segue.destination as? RateStarViewController
        }
    }
}

extension FoodCardViewController {
    func setFavourite(){
        var request = getRequestWithAuth("/favourites/")
        var json = [String:Any]()
        json["food_post_id"] = self.foodPost.id
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpMethod = "POST"
            request.httpBody = data
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
                // your stuff here
                guard let data = data else {
                    return
                }
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Int] else { return }
                    print(json)
                    DispatchQueue.main.async {
                        self.foodPost.favourite = json["favourite"] == 1
                        self.delegate?.changeMarker(foodPost: self.foodPost, image: self.imageWithImage(image: UIImage(named: self.foodPost.favourite! ? "marker_favourite" : "marker_seen")!, width: 40))
                        self.favouriteImageView.image = UIImage(named: self.foodPost.favourite! ? "favourite_star_fill" : "favourite_star")
                    }
                } catch let jsonErr {
                    print("json could'nt be parsed \(jsonErr)")
                }
            })
            task.resume()
        }catch{
        }
    }
}
