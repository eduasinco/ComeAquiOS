//
//  FoodLookViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import GoogleMaps

private class ResponseObject: Decodable{
    var user_status_in_this_post: String?
    var food_post: FoodPostObject?
}

class FoodLookViewController: KUIViewController {
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var image1: URLImageView!
    @IBOutlet weak var image2: URLImageView!
    @IBOutlet weak var image3: URLImageView!
    @IBOutlet weak var image1Width: NSLayoutConstraint!
    @IBOutlet weak var detailStackViewTopConstraint: NSLayoutConstraint!
    
        
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
    @IBOutlet weak var dinnersStackView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bcfkb: NSLayoutConstraint!
    var googleMap: GMSMapView!
    var foodPostId: Int!
    var foodPost: FoodPostObject?
    var commentsContainer: CommentsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentScrollView.delegate = self
        imageScrollView.delegate = self
        textView.delegate = self
        textView.isScrollEnabled = false
        self.bottomConstraintForKeyboard = bcfkb
        getFoodPost()
        detailStackViewTopConstraint.constant = headerView.frame.height
        
        sendButton.visibility = .gone
    }
    
    @IBAction func sendPress(_ sender: Any) {
        postComment()
    }
    
    func setViewDetails(){
        guard let foodPost = self.foodPost else {return}
        
        userName.text = foodPost.owner?.full_name!
        userUserName.text = foodPost.owner?.username!
        userImage.loadImageUsingUrlString(urlString: foodPost.owner!.profile_photo!)
        userImage.circle()
        
        let imageArray = [image1, image2, image3]
        imageScrollView.visibility = .visible
        imageScrollView.isHidden = false
        if foodPost.images!.count == 0 {
            imageScrollView.visibility = .gone
        } else if foodPost.images!.count == 1 {
            self.image1.loadImageUsingUrlString(urlString: foodPost.images![0].food_photo!)
            image1Width.constant = imageScrollView.frame.width
            image1.isHidden = false
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
        setDinners()
    }
    
    func createDinnerView(order: OrderObject) -> UIView {
        let dv = UIView()
        let imageView = URLImageView()
        dv.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        dv.addSubview(imageView)
        dv.widthAnchor.constraint(equalToConstant: dinnersStackView.frame.height).isActive = true

        imageView.leadingAnchor.constraint(equalTo: dv.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: dv.topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: dv.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: dv.bottomAnchor).isActive = true
        
        if order.additional_guests! > 0 {
            let label = UILabel()
            dv.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: dv.topAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: dv.trailingAnchor).isActive = true
            label.text = "\(order.additional_guests!)"
        }
        imageView.loadImageUsingUrlString(urlString: order.owner!.profile_photo!)
        dinnerImages.append(imageView)
        return dv
    }
    var dinnerImages: [URLImageView] = []
    func setDinners(){
        guard let confirmed_orders = self.foodPost?.confirmed_orders else { return }
        if confirmed_orders.count > 0 {
            dinnerImages = []
            for order in confirmed_orders {
                dinnersStackView.addArrangedSubview(createDinnerView(order: order))
            }
        } else {
            dinnersStackView.visibility = .gone
        }
    }
    
    override func viewDidLayoutSubviews() {
        for image in dinnerImages {
            image.circle()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentsSegue" {
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

extension FoodLookViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if textView.text.count > 0 {
            sendButton.visibility = .visible
        } else {
            sendButton.visibility = .gone
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}

extension FoodLookViewController {
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
    
    func postComment(){
        var request = getRequestWithAuth("/food_post_comment/\(self.foodPost!.id!)/")
        var json = [String:Any]()
        json["post_id"] = foodPost?.id ?? nil
        json["comment_id"] = nil
        json["message"] = textView.text!
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
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                    DispatchQueue.main.async {
                        let newComment = Comment(json: json, parent: nil)
                        self.commentsContainer?.commentAddedToPost(newComment: newComment)
                        
                        self.textView.text = ""
                        self.sendButton.visibility = .gone
                        UIView.animate(withDuration: 0.5) {
                            self.view.layoutIfNeeded()
                        }
                        self.dismiss(animated: true)
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
