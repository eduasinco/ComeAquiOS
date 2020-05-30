//
//  OrderLookViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 28/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class OrderLookViewController: LoadViewController, GMSMapViewDelegate {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var posterImage: URLImageView!
    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var posterUsername: UILabel!
    @IBOutlet weak var plateName: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var viewForMap: UIView!
    @IBOutlet weak var subtotal: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var confrimCancelView: UIStackView!
    
    var imageScrollVC: ImageScrollViewController?
    
    var orderId: Int?
    var order: OrderObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getOrder()
    }
    
    func setView(){
        guard let order = self.order else { return }
        posterImage.loadImageUsingUrlString(urlString: order.poster!.profile_photo)
        posterName.text = order.poster?.full_name
        posterUsername.text = order.poster?.username
        plateName.text = order.post?.plate_name
        status.text = order.order_status
        descriptionText.text = order.post?.description
        time.text = order.post?.time_to_show
        let priceF = Float(order.post!.price!) / 100
        let priceString =  "$" + priceF.format()
        price.text = priceString
        address.text = order.post?.formatted_address
        setMapView()
        subtotal.text = priceString
        total.text = priceString
        imageScrollVC?.foodPostId = self.order?.post!.id
    }
    func setMapView() {
        GMSServices.provideAPIKey("AIzaSyDDZzJN-1TJ9i8DzEvL-dJypS8Xsa2UYy0")
        let camera = GMSCameraPosition.camera(withLatitude: order!.post!.lat!, longitude: order!.post!.lng!, zoom: 15.0)
        let googleMap = GMSMapView.map(withFrame: view.bounds, camera: camera)
        googleMap.isMyLocationEnabled = true
        googleMap.delegate = self
        googleMap.isUserInteractionEnabled = false
        viewForMap.addSubview(googleMap)
        viewForMap.clipsToBounds = true
        setConfirmCancelButton()
        viewForMap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapMap(_:))))
    }
    func setConfirmCancelButton(){
        if order?.poster?.id == USER.id && order?.order_status == "PENDING" {
            confrimCancelView.visibility = .visible
        } else {
            confrimCancelView.visibility = .gone
        }
    }
    @objc func tapMap(_ gestureRecognizer: UITapGestureRecognizer) {
        openMap()
    }
    func goToGoogleMaps() {
         UIApplication.shared.canOpenURL(URL(string: "http://maps.apple.com/?ll=\(order!.post!.lat!),\(order!.post!.lng!)")!)
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(order!.post!.lat!),\(order!.post!.lng!)&zoom=14&views=traffic")!, options: [:], completionHandler: nil)
        } else {

        }
    }
    func openMap() {
        let appleURL = "http://maps.apple.com/?daddr=\(order!.post!.lat!),\(order!.post!.lng!)"
        let googleURL = "comgooglemaps://?daddr=\(order!.post!.lat!),\(order!.post!.lng!)&directionsmode=driving"
        let wazeURL = "waze://?ll=\(order!.post!.lat!),\(order!.post!.lng!)&navigate=false"

        let googleItem = ("Google Map", URL(string:googleURL)!)
        let wazeItem = ("Waze", URL(string:wazeURL)!)
        var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]

        if UIApplication.shared.canOpenURL(googleItem.1) {
            installedNavigationApps.append(googleItem)
        }

        if UIApplication.shared.canOpenURL(wazeItem.1) {
            installedNavigationApps.append(wazeItem)
        }

        let alert = UIAlertController(title: "Selection", message: "Select Navigation App", preferredStyle: .actionSheet)
        for app in installedNavigationApps {
            let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                UIApplication.shared.open(app.1, options: [:], completionHandler: nil)
            })
            alert.addAction(button)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @IBAction func goToMealPressed(_ sender: Any) {
        performSegue(withIdentifier: "FoodLookSegue", sender: nil)
    }
    @IBAction func optionsPressed(_ sender: Any) {
        performSegue(withIdentifier: "OptionsSegue", sender: nil)
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        setOrderStatus("CONFIRMED")
    }
    @IBAction func cancelPressed(_ sender: Any) {
        setOrderStatus("CANCELED")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OptionsSegue" {
            let optionsVC = segue.destination as? OptionsPopUpViewController
            guard let order = self.order else {return}
            var options: [String] = []
            options.append("Help");
            if (order.order_status == "CONFIRMED" || order.order_status == "PENDING"){
                options.append("Cancel order");
            }
            optionsVC?.options = options
            optionsVC?.delegate = self
        } else if segue.identifier == "FoodLookSegue" {
            let foodLookContainer = segue.destination as? FoodLookViewController
            foodLookContainer?.foodPostId = self.order?.post!.id
        } else if segue.identifier == "ImageScrollSegue" {
            imageScrollVC = segue.destination as? ImageScrollViewController
        }
    }
}
extension OrderLookViewController: OptionsPopUpProtocol{
    func optionPressed(_ title: String) {
        switch title {
        case "Help":
            break
        case "Cancel order":
            setOrderStatus("CANCELED")
        case "Report":
            break
            // reportPost()
        default:
            break
        }
    }
}
extension OrderLookViewController {
    func getOrder(){
        presentLoader()
        guard let orderId = self.orderId else { return }
        Server.get( "/order_detail/\(orderId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            self.closeLoader()
            guard let data = data else {return}
            if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {}
            do {
                self.order = try JSONDecoder().decode(OrderObject.self, from: data)
                DispatchQueue.main.async {
                    self.setView()
                }
            } catch {}
        })
    }
    
    func setOrderStatus(_ status: String){
        Server.post("/set_order_status/",
            json:
            [
                "order_id": self.order!.id!,
                "order_status": status,
            ],
            finish: {(data: Data?, response: URLResponse?) in
                guard let data = data else {return}
                do {
                    self.order = try JSONDecoder().decode(OrderObject.self, from: data)
                    DispatchQueue.main.async {
                        self.setView()
                    }
                } catch {}
        })
    }
}
