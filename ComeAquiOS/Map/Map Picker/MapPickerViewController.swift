//
//  MapPickerViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
protocol MapPickerProtocol {
    func markerVisibility(_ visible: Bool)
    func buttonPressed(times: Int)
    func goToAddFood(googleLocation: PlaceG?)
    func placeSelected(place: PlaceG?)
}
class MapPickerViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pan: UIView!
    @IBOutlet weak var handle: UIView!
    @IBOutlet weak var picker: UIView!
    @IBOutlet weak var bottomPickerConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerShadow: UIImageView!
    @IBOutlet weak var pickerShadowLeading: NSLayoutConstraint!
    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var pickerPoint: UIView!
    @IBOutlet weak var bottomPickerPointConstraint: NSLayoutConstraint!
    
    var searchAbailable = false
    var placeFromGoogle: PlaceG?
    var fabCount = 0
    var delegate: MapPickerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomPickerConstraint.constant = view.frame.height / 2
        pan.roundCorners(radius: pan.frame.height/2).border(witdth: handle.frame.width - 1, color: UIColor(named: "Primary")!.cgColor)
        label.roundCorners(radius: label.frame.height/2)
        handle.circle()
        searchContainerView.visibility = .gone
        picker.visibility = .gone
        
        pickerButton.roundCorners(radius: pickerButton.frame.height/2).dropShadow()
        searchContainerView.textFieldBorderStyle()
        
    }
    @IBAction func addFoodPressed(_ sender: Any) {
        if (fabCount == 0){
            delegate?.markerVisibility(false)
            fabCount = 1
            searchAbailable = true
            switchFabImage(true)
            picker.visibility = .visible
            searchContainerView.visibility = .visible
            delegate?.buttonPressed(times: fabCount)
        } else if (fabCount == 1) {
            delegate?.goToAddFood(googleLocation: self.placeFromGoogle)
        } else {
            fabCount = 2
            switchFabImage(false)
        }
    }
    
    func switchFabImage(_ toPLus: Bool){
        pickerButton.setImage(UIImage(systemName: toPLus ? "plus": "plus.magnifyingglass"), for: UIControl.State.normal)
    }
    
    func animate(up: Bool = true) {
        UIView.animate(withDuration: 0.2){
            let move: CGFloat = 20
            self.bottomPickerConstraint.constant = up ?  self.view.frame.height / 2 + move : self.view.frame.height / 2
            self.pickerShadowLeading.constant = up ?  move/2 : 0
            self.bottomPickerPointConstraint.constant = up ? -move : 0
            self.pickerPoint.transform = CGAffineTransform(scaleX: up ? 1 : 0.6, y: up ? 1 : 0.6)
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaceAutocompleteSegue" {
            let placeAutocompleteContainer = segue.destination as? PlaceAutocompleteViewController
            placeAutocompleteContainer?.delegate = self
        }
    }
}

extension MapPickerViewController: AutocompleteProtocol {
    func close() {
        searchAbailable = false
        fabCount = 0
        switchFabImage(false)
        searchContainerView.visibility = .gone
        picker.visibility = .gone
    }
    
    func placeSelected(place: PlaceG?) {
        delegate?.placeSelected(place: place)
    }
}

extension MapPickerViewController{
    func getLocationFromGoogle(lat: Double, lng: Double){
        if searchAbailable {
            guard let endpointUrl = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(lng)&key=\(GOOGLE_KEY)") else { return }
            
            var request = URLRequest(url: endpointUrl)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "GET"
            let session = URLSession(configuration: URLSessionConfiguration.default)
            self.label.text = "Loading..."
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                    guard let data = data else {
                    return
                }
                do {
                    let googleMapsLocation = try JSONDecoder().decode(GoogleMapsLocation.self, from: data)
                    DispatchQueue.main.async {
                        if (googleMapsLocation.results.count) > 0 {
                            self.getPlaceDetailFromGoogle(placeId: googleMapsLocation.results[0].place_id!)
                        }
                    }
                } catch _ {
                    self.view.showToast(message: "Some error ocurred")
                }
            })
            task.resume()
        }
    }
    func getPlaceDetailFromGoogle(placeId: String){
        guard let endpointUrl = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?input=bar&placeid=\(placeId)&key=\(GOOGLE_KEY)") else { return }
        
        var request = URLRequest(url: endpointUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        self.label.text = "Loading..."
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                guard let data = data else {
                return
            }
            do {
                self.placeFromGoogle = try JSONDecoder().decode(PlaceG.self, from: data)
                DispatchQueue.main.async {
                    self.label.text = self.placeFromGoogle?.result?.formatted_address
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
        task.resume()
    }
}

class GoogleMapsLocation: Decodable {
    var plus_code: PlusCode?
    var results: [ResultsG]!
}
class PlusCode: Decodable{
    var compound_code: String?
    var global_code: String?
}
class ResultsG: Decodable  {
    var address_components: [AddressComponentG]?
    var formatted_address: String?
    var geometry: GeometryG?
    var place_id: String?
    var plus_code: PlusCode?
    var types: [String]?
}
class AddressComponentG: Decodable  {
    var long_name: String?
    var short_name: String?
    var types: [String]?
}
class GeometryG: Decodable{
    var location: LocationG?
    var location_type: String?
    var viewport: ViewPortG?
    
}
class LocationG: Decodable{
    var lat: Double?
    var lng: Double?
}
class ViewPortG: Decodable{
    var northeast: LocationG?
    var southwest: LocationG?
}


