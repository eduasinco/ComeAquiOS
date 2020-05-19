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
import Starscream


private class FoodPostMarker : GMSMarker {
    var id : Int!
}

class MapViewController: LoadViewController, CardActionProtocol {
    
    
    @IBOutlet weak var viewForMap: UIView!
    var googleMap: GMSMapView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mapPickerContainerView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var cardBottomConstraint: NSLayoutConstraint!
    
    var foodPosts: [FoodPostObject]?
    var favouritePosts: [FavouritePost]?
    var foodPostsDict: [Int: FoodPostObject] = [:]
    private var idToMarker: [Int: FoodPostMarker] = [:]
    private var markers: [FoodPostMarker] = []
    
    var myLocation: CLLocation?
    let locationManager = CLLocationManager()
    var foodCardVC: FoodCardViewController?
    var mapPickerContainer: MapPickerViewController!
    
    var currentPost: FoodPostObject!
    var lastPost: FoodPostObject?
    var seenPost = Set<Int>()
    
    var cameraLat: Double?
    var cameraLng: Double?
    
    var ws: WebSocket?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.navigationController?.setNavigationBarHidden(true, animated: false)
        GMSServices.provideAPIKey("AIzaSyDDZzJN-1TJ9i8DzEvL-dJypS8Xsa2UYy0")
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15.0)
        googleMap = GMSMapView.map(withFrame: view.bounds, camera: camera)
        googleMap.isMyLocationEnabled = true
        googleMap.isMyLocationEnabled = true
        googleMap.delegate = self
        self.viewForMap.addSubview(googleMap)
        checkLocationServices()
        getFoodPosts()
        
        moveCardToBottom(view: cardView)
        addPanGesture(view: cardView)
        view.bringSubviewToFront(cardView)
        
        webSocketConnetion()
        
//        if let tabItems = tabBarController?.tabBar.items {
//            // In this case we want to modify the badge number of the third tab:
//            let tabItem = tabItems[0]
//            tabItem.badgeValue = nil
//        }
    }
    override func viewDidLayoutSubviews() {
        containerView.roundCorners(radius: 8, clip: true)
        cardView.roundCorners(radius: 8).dropShadow()
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
            
            markers.append(marker)
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
    
    func showCard(foodPostId: Int){
        self.lastPost = currentPost
        let fp = self.foodPostsDict[foodPostId]
        guard let currentPost = fp else { return }
        self.currentPost = currentPost
        foodCardVC?.setView(foodPost: currentPost)
        if let lastPost = self.lastPost {
            if let lastPostFavourite = self.lastPost?.favourite {
                changeMarker(foodPost: lastPost, image: self.imageWithImage(image: UIImage(named: lastPostFavourite ? "marker_favourite" : "marker_seen")!, width: 30))
            } else {
                changeMarker(foodPost: lastPost, image: self.imageWithImage(image: UIImage(named: "marker_seen")!, width: 30))
            }
        }
        
        if let favourite = self.currentPost.favourite  {
            changeMarker(foodPost: self.currentPost, image: self.imageWithImage(image: UIImage(named: favourite ? "marker_favourite" :(seenPost.contains(currentPost.id!) ? "marker_seen" : "marker"))!, width: 40))
        } else {
            changeMarker(foodPost: self.currentPost,image: self.imageWithImage(image: UIImage(named: "marker_seen")!, width: 30))
            changeMarker(foodPost: self.currentPost, image: self.imageWithImage(image: UIImage(named: seenPost.contains(currentPost.id!) ? "marker_seen" : "marker")!, width: 40))
        }
        returnViewToOrigin(view: cardView)
        seenPost.insert(currentPost.id!)
    }
    
    func addPanGesture(view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MapViewController.handlePan(sender:)))
        view.addGestureRecognizer(pan)
    }
    
    var originY: CGFloat!
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let cardView = sender.view!
        
        switch sender.state {
        case .began:
            moveViewWithPan(view: cardView, sender: sender)
            originY = cardView.frame.origin.y
        case .changed:
            moveViewWithPan(view: cardView, sender: sender)
        case .ended:
            let move = cardView.frame.origin.y - originY
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
        self.cardBottomConstraint.constant = 8 - max(0, translation.y)
    }
    func returnViewToOrigin(view: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            self.cardBottomConstraint.constant = 8
            self.view.layoutIfNeeded()
        })
    }
    func moveCardToBottom(view: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            self.cardBottomConstraint.constant = -(8 + self.cardView.frame.height + 200)
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
        default:
            break
        }
    }
    
    func goToFoodLook(){
        performSegue(withIdentifier: "FoodLookSegue", sender: self.currentPost.id)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FoodCardSegue" {
            foodCardVC = segue.destination as? FoodCardViewController
            foodCardVC?.delegate = self
            foodCardVC?.foodPost = sender as? FoodPostObject
        } else if segue.identifier == "FoodLookSegue" {
            let foodLookContainer = segue.destination as? FoodLookViewController
            foodLookContainer?.foodPostId = sender as? Int
        } else if segue.identifier == "MapPickerSegue" {
            mapPickerContainer = segue.destination as? MapPickerViewController
            mapPickerContainer.delegate = self
        } else if segue.identifier == "AddFoodSegue" {
            let addFoodVC = segue.destination as? AddFoodViewController
            addFoodVC?.location = sender as? PlaceG
        } else if segue.identifier == "SearchSegue" {
            let addFoodVC = segue.destination as? SearchViewController
            addFoodVC?.initialLocation = self.myLocation
        }
    }
}
extension MapViewController: MapPickerProtocol {
    func placeSelected(place: PlaceG?) {
        guard let place = place else { return }
        let camera = GMSCameraPosition.camera(withLatitude: (place.result?.geometry?.location?.lat!)!, longitude: (place.result?.geometry?.location?.lng!)!, zoom: 16)
        googleMap?.camera = camera
        googleMap?.animate(to: camera)
    }
    
    func buttonPressed(times: Int) {
        guard let cameraLat = self.cameraLat, let cameraLng = self.cameraLng else { return }
        mapPickerContainer.getLocationFromGoogle(lat: cameraLat, lng: cameraLng)
    }
    
    func goToAddFood(googleLocation: PlaceG?) {
        performSegue(withIdentifier: "AddFoodSegue", sender: googleLocation)
    }
    
    func markerVisibility(_ visible: Bool) {
        for marker in markers {
            marker.map = visible ? nil : googleMap
        }
    }
    
}

extension MapViewController {
    func getFoodPosts(){
        Server.get("/foods/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
            }
            guard let data = data else {
                return
            }
            do {
                self.foodPosts = try JSONDecoder().decode([FoodPostObject].self, from: data)
                DispatchQueue.main.async {
                    self.setMarkers()
                    self.getFavouritesPosts()
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
    }
    
    func getFavouritesPosts(){
        Server.get("/my_favourites/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
            }
            guard let data = data else {
                return
            }
            do {
                self.favouritePosts = try JSONDecoder().decode([FavouritePost].self, from: data)
                DispatchQueue.main.async {
                    self.setFavouriteMarkers()
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations.last
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
        showCard(foodPostId: marker.id)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        mapPickerContainer.label.text = ""
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition){
        cameraLat = mapView.camera.target.latitude
        cameraLng = mapView.camera.target.longitude
        mapPickerContainer.getLocationFromGoogle(lat: cameraLat!,  lng: cameraLng!)
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MapViewController: WebSocketDelegate{
    private class SocketObject: Decodable {
        var message: MessageResponseObject?
    }
    private class MessageResponseObject: Decodable {
        var post: FoodPostObject?
        var delete: Bool?

    }
    func webSocketConnetion(){
        var request = URLRequest(url: URL(string: SERVER + "/ws/orders/\(USER.id!)/")!)
        request.timeoutInterval = 5
        ws = WebSocket(request: request)
        ws?.delegate = self
        ws?.connect()
    }
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            // isConnected = true
            print("CONEETEEEEEEEEEEEEEEEEEEEEEEEEEEEED")
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            // isConnected = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.ws?.connect()
                print("WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEB")
            })
            print("DISCONEETEEEEEEEEEEEEEEEEEEEEEEEEEEEED \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            let data = string.data(using: .utf8)!
            do {
                let so = try JSONDecoder().decode(SocketObject.self, from: data)
                guard let mro = so.message else {return}
                if let delete = mro.delete, delete {
                    if let marker = idToMarker[mro.post!.id!] {
                        marker.map = nil
                    }
                } else {
                    if foodPostsDict[mro.post!.id!] == nil {
                        foodPostsDict[mro.post!.id!] = mro.post!
                        let marker = FoodPostMarker()
                        marker.id = mro.post!.id!
                        marker.position = CLLocationCoordinate2D(latitude: mro.post!.lat!, longitude: mro.post!.lng!)
                        marker.title = mro.post!.plate_name!
                        marker.map = self.googleMap
                        marker.icon = self.imageWithImage(image: mro.post!.favourite! ? UIImage(named: "marker_favourite")! : UIImage(named: "marker")!, width: 30)
                        idToMarker[marker.id] = marker
                    }
                }
                DispatchQueue.main.async {
                }
            } catch let error as NSError {
                print(error)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            // isConnected = false
            break
        case .error(let error):
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.ws?.connect()
                print("WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEB")
            })
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ws?.disconnect()
    }
}

