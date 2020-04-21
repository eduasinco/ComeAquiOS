//
//  MapPickerViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class MapPickerViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pan: UIView!
    @IBOutlet weak var handle: UIView!
    @IBOutlet weak var picker: UIView!
    @IBOutlet weak var middleYPicker: NSLayoutConstraint!
    
    var googleMapsLocation: GoogleMapsLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        middleYPicker.constant = -picker.frame.height / 2
        pan.roundCorners(radius: pan.frame.height/2).border(witdth: handle.frame.width)
        label.roundCorners(radius: label.frame.height/2)
        handle.circle()
    }
}

extension MapPickerViewController{
    func getLocationFromGoogle(lat: Double, lng: Double){
        guard var endpointUrl = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(lng)&key=\(GOOGLE_KEY)") else { return }
        
        var request = URLRequest(url: endpointUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                guard let data = data else {
                return
            }
            do {
                self.googleMapsLocation = try JSONDecoder().decode(GoogleMapsLocation.self, from: data)
                DispatchQueue.main.async {
                    if (self.googleMapsLocation?.results.count)! > 0 {
                        self.label.text = self.googleMapsLocation!.results[0].formatted_address
                    }
                }
            } catch let jsonErr {
                print("json could'nt be parsed \(jsonErr)")
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


