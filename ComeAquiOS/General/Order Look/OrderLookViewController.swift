//
//  OrderLookViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 28/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import GoogleMaps

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
        time.text = order.post?.start_time
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
        googleMap.isMyLocationEnabled = true
        googleMap.delegate = self
        viewForMap.addSubview(googleMap)
        viewForMap.clipsToBounds = true
        viewForMap.isUserInteractionEnabled = false
        setConfirmCancelButton()
    }
    func setConfirmCancelButton(){
        if order?.poster?.id == USER.id && order?.order_status == "PENDING" {
            confrimCancelView.visibility = .visible
        } else {
            confrimCancelView.visibility = .gone
        }
        
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
        present(alert, animated: false, completion: nil)
        guard let orderId = self.orderId else { return }
        Server.get( "/order_detail/\(orderId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                self.alert.dismiss(animated: false, completion: nil)
            }
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
        present(alert, animated: false, completion: nil)
        Server.post("/set_order_status/",
            json:
            [
                "order_id": self.order!.id!,
                "order_status": status,
            ],
            finish: {(data: Data?, response: URLResponse?) in
                DispatchQueue.main.async {
                    self.alert.dismiss(animated: false, completion: nil)
                }
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
