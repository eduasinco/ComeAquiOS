//
//  FoodLookViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import GoogleMaps

class ResponseObject: Decodable{
    var user_status_in_this_post: String?
    var food_post: FoodPostObject?
}

class FoodLookViewController: UIViewController {
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var image1: URLImageView!
    @IBOutlet weak var image2: URLImageView!
    @IBOutlet weak var image3: URLImageView!
    @IBOutlet weak var image1Width: NSLayoutConstraint!
    @IBOutlet weak var image2Width: NSLayoutConstraint!
    @IBOutlet weak var image3Width: NSLayoutConstraint!
    @IBOutlet weak var detailViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var shortHeaderView: UIView!
    @IBOutlet weak var userImage: URLImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUserName: UILabel!
    
    @IBOutlet weak var plateName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var mealDescription: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var viewToShowMap: UIView!
        
    var googleMap: GMSMapView!
    var foodPostId: Int!
    var foodPost: FoodPostObject?
    var commentsContainer: CommentsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentScrollView.delegate = self
        imageScrollView.delegate = self
        getFoodPost()
        detailViewTopConstraint.constant = headerView.frame.height
    }
    
    
    func setViewDetails(){
        guard let foodPost = self.foodPost else {return}
        
        userName.text = foodPost.owner?.full_name!
        userUserName.text = foodPost.owner?.username!
        userImage.loadImageUsingUrlString(urlString: foodPost.owner!.profile_photo!)
        userImage.circle()
        
        let imageArray = [image1, image2, image3]
        let imageWidthArray = [image1Width, image2Width, image3Width]
        imageScrollViewHeight.constant = 200
        imageScrollView.isHidden = false
        if foodPost.images!.count == 0 {
            imageScrollViewHeight.constant = 0
            imageScrollView.isHidden = true
        } else if foodPost.images!.count == 1 {
            self.image1.loadImageUsingUrlString(urlString: foodPost.images![0].food_photo!)
            image1Width.constant = imageScrollView.frame.width
            image1.isHidden = false
        } else {
            for (i, image) in foodPost.images!.enumerated(){
                imageWidthArray[i]!.constant = 300
                imageArray[i]!.isHidden = false
                imageArray[i]!.loadImageUsingUrlString(urlString: image.food_photo!)
            }
        }
        var i = foodPost.images!.count
        while i < imageArray.count {
            imageWidthArray[i]!.constant = 0
            imageArray[i]!.isHidden = true
            i += 1
        }
        
        plateName.text = foodPost.plate_name
        date.text = Date.hhmmHappenedNowTodayYesterdayWeekDay(start: foodPost.start_time!, end: foodPost.end_time!)
        time.text = Date.timeRange(start: foodPost.start_time!, end: foodPost.end_time!)
        price.text = "$" + String(format:"%.2f", Double(foodPost.price!) / 100)
        mealDescription.text = foodPost.description
        addressLabel.text = foodPost.formatted_address
        
        GMSServices.provideAPIKey("AIzaSyDDZzJN-1TJ9i8DzEvL-dJypS8Xsa2UYy0")
        let camera = GMSCameraPosition.camera(withLatitude: foodPost.lat!, longitude: foodPost.lng!, zoom: 15.0)
        googleMap = GMSMapView.map(withFrame: view.bounds, camera: camera)
        googleMap.isMyLocationEnabled = true
        googleMap.isMyLocationEnabled = true
        googleMap.delegate = self
        viewToShowMap.addSubview(googleMap)
        viewToShowMap.clipsToBounds = true
        viewToShowMap.isUserInteractionEnabled = false
    }
    
    func getFoodPost(){
        guard let foodPostId = self.foodPostId else { return }
        var request = getRequestWithAuth("/food_with_user_status/\(foodPostId)/")
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            guard let data = data else {
                return
            }
            do {
                self.foodPost = try JSONDecoder().decode(ResponseObject.self, from: data).food_post
                DispatchQueue.main.async {
                    self.setViewDetails()
                }
            } catch {
            }
        })
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            commentsContainer = segue.destination as? CommentsViewController
            commentsContainer?.foodPostId = self.foodPostId
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FoodLookViewController: GMSMapViewDelegate {
    @objc(mapView:didTapMarker:) func mapView(_: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }
}

extension FoodLookViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == parentScrollView{
            if scrollView.contentOffset.y > headerView.frame.height - shortHeaderView.frame.height {
                headerTopConstraint.constant = -headerView.frame.height + shortHeaderView.frame.height + scrollView.contentOffset.y
                headerView.dropShadow(radius: 5, opacity: 5)
            } else {
                headerTopConstraint.constant = 0
                headerView.dropShadow()
            }
        }
    }
}
