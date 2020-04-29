//
//  OrderLookViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 28/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import GoogleMaps

class OrderLookViewController: UIViewController, GMSMapViewDelegate {
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
    
    var orderId: Int?
    var order: OrderObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getOrder()
    }
    
    func setView(){
        guard let order = self.order else { return }
        posterImage.loadImageUsingUrlString(urlString: order.poster!.profile_photo!)
        posterName.text = order.poster?.full_name
        posterUsername.text = order.poster?.username
        plateName.text = order.post?.plate_name
        status.text = order.order_status
        descriptionText.text = order.post?.description
        time.text = order.post?.start_time
        let priceF = Float(order.post!.price!) / 100
        let priceString =  "$" + priceF.format()
        price.text = priceString
        address.text = order.post?.formatted_address
        setMapView()
        subtotal.text = priceString
        total.text = priceString
    }
    
    func setMapView() {
        GMSServices.provideAPIKey("AIzaSyDDZzJN-1TJ9i8DzEvL-dJypS8Xsa2UYy0")
        let camera = GMSCameraPosition.camera(withLatitude: order!.post!.lat!, longitude: order!.post!.lng!, zoom: 15.0)
        let googleMap = GMSMapView.map(withFrame: view.bounds, camera: camera)
        googleMap.isMyLocationEnabled = true
        googleMap.isMyLocationEnabled = true
        googleMap.delegate = self
        viewForMap.addSubview(googleMap)
        viewForMap.clipsToBounds = true
        viewForMap.isUserInteractionEnabled = false
    }
    
    @IBAction func goToMealPressed(_ sender: Any) {
        performSegue(withIdentifier: "FoodLookSegue", sender: nil)
    }
    @IBAction func optionsPressed(_ sender: Any) {
        performSegue(withIdentifier: "OptionsSegue", sender: nil)

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
        }
    }
}
extension OrderLookViewController: OptionsPopUpProtocol{
    func optionPressed(_ title: String) {
        switch title {
        case "Help":
            break
        case "Cancel order":
            cancelOrder()
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
        guard let orderId = self.orderId else { return }
        Server.get( "/order_detail/\(orderId)/", finish: {(data: Data?) -> Void in
            guard let data = data else {return}
            do {
                self.order = try JSONDecoder().decode(OrderObject.self, from: data)
                DispatchQueue.main.async {
                    self.setView()
                }
            } catch {}
        }, error: {(data: Data?) -> Void in})
    }
    
    func cancelOrder(){
        Server.post("/set_order_status/",
            json:
            [
                "order_id": self.order!.id!,
                "order_status": "CANCELED",
            ],
            finish: {(data: Data?) in
                guard let data = data else {
                    return
                }
                do {
                    let _ = try JSONDecoder().decode(OrderObject.self, from: data)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                } catch {}
        }, error: {(data: Data?) in})
    }
}
