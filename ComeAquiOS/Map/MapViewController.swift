//
//  MapViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//


import UIKit
import MapKit
import GoogleMaps
import CoreLocation

private class FoodPostMarker : GMSMarker {
    var id : Int!
}

class MapViewController: UIViewController {
    
    
    @IBOutlet weak var viewForMap: UIView!
    var googleMap: GMSMapView!
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageScrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var image1: URLImageView!
    @IBOutlet weak var image1Width: NSLayoutConstraint!
    @IBOutlet weak var image2: URLImageView!
    @IBOutlet weak var image2Width: NSLayoutConstraint!
    @IBOutlet weak var image3: URLImageView!
    @IBOutlet weak var image3Width: NSLayoutConstraint!
    @IBOutlet weak var userImage: URLImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    @IBOutlet weak var favouriteImageView: UIImageView!
    @IBOutlet weak var plateName: UILabel!
    @IBOutlet weak var mealDescription: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var foodPosts: [FoodPostObject]?
    var favouritePosts: [FavouritePost]?
    var foodPostsDict: [Int: FoodPostObject] = [:]
    private var idToMarker: [Int: FoodPostMarker] = [:]

    
    let locationManager = CLLocationManager()
    @IBOutlet weak var cardBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var plateNameStack: UIStackView!
    var cardViewOrigin: CGPoint!
            
    var typesContainer: TypesViewController!
    var rateContainer: RateStarViewController!
    var foodLookContainer: FoodLookViewController!

    var currentPost: FoodPostObject!
    var lastPost: FoodPostObject?
    var seenPost = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GMSServices.provideAPIKey("AIzaSyDDZzJN-1TJ9i8DzEvL-dJypS8Xsa2UYy0")
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15.0)
        googleMap = GMSMapView.map(withFrame: view.bounds, camera: camera)
        googleMap.isMyLocationEnabled = true
        googleMap.isMyLocationEnabled = true
        googleMap.delegate = self
        self.viewForMap.addSubview(googleMap)
        checkLocationServices()
        getFoodPosts()
        
        userImage.circle()
        cardView.roundCorners(radius: 8)
        
        cardViewOrigin = cardView.frame.origin
        moveCardToBottom(view: cardView)
        addPanGesture(view: cardView)
        view.bringSubviewToFront(cardView)
        setFavouriteClickListener()
        setFoodLookClickListener()
    }
    
    func setFoodLookClickListener(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(goToFoodLook))
        mealDescription.isUserInteractionEnabled = true
        mealDescription.addGestureRecognizer(singleTap)
    }
    @objc func goToFoodLook(){
//        let storyBoard : UIStoryboard = UIStoryboard(name: "FoodLookStoryboard", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FoodLook") as! FoodLookViewController
//        self.present(nextViewController, animated:true, completion:nil)
        
        performSegue(withIdentifier: "FoodLookSegue", sender: self.currentPost.id)
    }
    
    func setFavouriteClickListener(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        favouriteImageView.isUserInteractionEnabled = true
        favouriteImageView.addGestureRecognizer(singleTap)
    }
    @objc func tapDetected() {
        setFavourite()
    }
    func getFoodPosts(){
        var request = getRequestWithAuth("/foods/")
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        spinner.startAnimating()
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
            guard let data = data else {
                return
            }
            do {
                self.foodPosts = try JSONDecoder().decode([FoodPostObject].self, from: data)
                DispatchQueue.main.async {
                    self.setMarkers()
                    self.getFavouritesPosts()
                }
            } catch let jsonErr {
                print("json could'nt be parsed \(jsonErr)")
            }
        })
        task.resume()
    }
    
    func getFavouritesPosts(){
        var request = getRequestWithAuth("/my_favourites/")
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        spinner.startAnimating()
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
                guard let data = data else {
                return
            }
            do {
                self.favouritePosts = try JSONDecoder().decode([FavouritePost].self, from: data)
                DispatchQueue.main.async {
                    self.setFavouriteMarkers()
                }
            } catch let jsonErr {
                print("json could'nt be parsed \(jsonErr)")
            }
        })
        task.resume()
    }
    
    func setFavourite(){
        var request = getRequestWithAuth("/favourites/")
        var json = [String:Any]()
        json["food_post_id"] = currentPost.id
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
                        self.currentPost.favourite = json["favourite"] == 1
                        self.changeMarker(foodPost: self.currentPost,image: self.imageWithImage(image: UIImage(named: self.currentPost.favourite! ? "marker_favourite" : "marker_seen")!, width: 40))
                        self.favouriteImageView.image = UIImage(named: self.currentPost.favourite! ? "favourite_star_fill" : "favourite_star")
                    }
                } catch let jsonErr {
                    print("json could'nt be parsed \(jsonErr)")
                }
            })
            task.resume()
        }catch{
        }
    }
    
    func setMarkers(){
        guard let foodPosts = foodPosts else {return}
        for fp in foodPosts{
            self.foodPostsDict[fp.id!] = fp
            
            let marker = FoodPostMarker()
            marker.id = fp.id
            marker.position = CLLocationCoordinate2D(latitude: fp.lat!, longitude: fp.lng!)
            marker.title = fp.plate_name!
            marker.map = self.googleMap
            marker.icon = self.imageWithImage(image: UIImage(named: "marker")!, width: 30)
            idToMarker[marker.id] = marker
        }
    }
    
    func setFavouriteMarkers(){
        guard let favorutieFoodPosts = favouritePosts else {return}
        for ffp in favorutieFoodPosts{
            let foodPost = foodPostsDict[ffp.post!.id!]
            foodPost!.favourite = true
            self.changeMarker(foodPost: foodPost!, image: self.imageWithImage(image: UIImage(named: "marker_favourite")!, width: 30))
        }
    }
    
    func changeMarker(foodPost: FoodPostObject, image: UIImage){
        let marker = self.idToMarker[foodPost.id!]
        marker!.icon = image
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
    
    
    func showCard(_ foodPostId: Int){
        let fp = self.foodPostsDict[foodPostId]
        guard let foodPost = fp else { return }
        self.lastPost = currentPost
        self.currentPost = fp
        if let lastPost = self.lastPost {
            if let lastPostFavourite = self.lastPost?.favourite {
                changeMarker(foodPost: lastPost, image: self.imageWithImage(image: UIImage(named: lastPostFavourite ? "marker_favourite" : "marker_seen")!, width: 30))
            } else {
                changeMarker(foodPost: lastPost, image: self.imageWithImage(image: UIImage(named: "marker_seen")!, width: 30))
            }
        }
        
        if let favourite = self.currentPost.favourite  {
            favouriteImageView.image = UIImage(named: favourite ? "favourite_star_fill" : "favourite_star")
            changeMarker(foodPost: self.currentPost, image: self.imageWithImage(image: UIImage(named: favourite ? "marker_favourite" :(seenPost.contains(currentPost.id!) ? "marker_seen" : "marker"))!, width: 40))
        } else {
            changeMarker(foodPost: self.currentPost,image: self.imageWithImage(image: UIImage(named: "marker_seen")!, width: 30))
            changeMarker(foodPost: self.currentPost, image: self.imageWithImage(image: UIImage(named: seenPost.contains(currentPost.id!) ? "marker_seen" : "marker")!, width: 40))
            favouriteImageView.image = UIImage(named: "favourite_star")
        }
        
//        let cameraPosition = GMSCameraPosition.camera(withTarget: CLLocationCoordinate2D(latitude: currentPost.lat!, longitude: currentPost.lng!), zoom: 15)
//        googleMap.animate(to: cameraPosition)
        
        let imageArray = [image1, image2, image3]
        let imageWidthArray = [image1Width, image2Width, image3Width]
        imageScrollViewHeight.constant = 100
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
                imageWidthArray[i]!.constant = 260
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
        userImage.loadImageUsingUrlString(urlString: foodPost.owner!.profile_photo!)
        userName.text = foodPost.owner!.full_name!
        userUsername.text = foodPost.owner!.username!
        mealDescription.text = foodPost.description!
        plateName.text = foodPost.plate_name!
        time.text = Date.hhmmHappenedNowTodayYesterdayWeekDay(start: foodPost.start_time!, end: foodPost.end_time!)
        price.text = "$" + String(format:"%.2f", Double(foodPost.price!) / 100)
        cardView.layoutIfNeeded()
        typesContainer.setTypes(typeString: foodPost.food_type ?? "0000000")
        rateContainer.setRate(rating: foodPost.owner!.rating!, rating_n: foodPost.owner!.rating_n!)
        
        returnViewToOrigin(view: cardView)
        seenPost.insert(currentPost.id!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypeSegue" {
            typesContainer = segue.destination as? TypesViewController
        } else if segue.identifier == "RateSegue" {
            rateContainer = segue.destination as? RateStarViewController
        } else if segue.identifier == "FoodLookSegue" {
            foodLookContainer = segue.destination as? FoodLookViewController
            foodLookContainer.foodPostId = sender as! Int
        }
    }
    
    func addPanGesture(view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MapViewController.handlePan(sender:)))
        view.addGestureRecognizer(pan)
    }
    
    // Refactor
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let cardView = sender.view!
        
        switch sender.state {
        case .began, .changed:
            moveViewWithPan(view: cardView, sender: sender)
        case .ended:
            let move = cardView.frame.origin.y - cardViewOrigin.y
            print(move)
            if move >= 100 {
                moveCardToBottom(view: cardView)
                if let favourite = self.currentPost?.favourite {
                    changeMarker(foodPost: currentPost, image: self.imageWithImage(image: UIImage(named: favourite ? "marker_favourite" : "marker_seen")!, width: 30))
                } else {
                    changeMarker(foodPost: currentPost, image: self.imageWithImage(image: UIImage(named: "marker_seen")!, width: 30))
                }
            } else {
                returnViewToOrigin(view: cardView)
            }
        default:
            break
        }
    }
    
    
    func moveViewWithPan(view: UIView, sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        self.cardBottomConstraint.constant = -8 + translation.y
    }
    func returnViewToOrigin(view: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            self.cardBottomConstraint.constant = -8
            self.view.layoutIfNeeded()
        })
    }
    func moveCardToBottom(view: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            self.cardBottomConstraint.constant = 8 + self.cardView.frame.height
            self.view.layoutIfNeeded()
        })
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            googleMap.camera = GMSCameraPosition.camera(withTarget: location, zoom: 15)
        }
    }
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerViewOnUserLocation()
        locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapViewController: GMSMapViewDelegate {
    @objc(mapView:didTapMarker:) func mapView(_: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let marker = marker as! FoodPostMarker
        showCard(marker.id)
        return true
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

