//
//  PlaceAutocompleteViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
protocol AutocompleteProtocol {
    func close()
    func placeSelected(place: PlaceG?)
}

class PlaceAutocompleteViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: ValidatedTextField!
    @IBOutlet weak var tableView: MyOwnTableView!
    @IBOutlet weak var clearTextButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var places: [PredictionG] = []
    var selectedPlace: PlaceG?
    var closeVisible: Bool = true

    var delegate: AutocompleteProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        // tableView.isScrollEnabled = false
        textField.addTarget(self, action: #selector(textField(_:shouldChangeCharactersIn:replacementString:)), for: .editingChanged)
        
        clearTextButton.visibility = .gone
        closeButton.visibility = closeVisible ? .visible : .gone

    }
    @IBAction func clearText(_ sender: Any) {
        textField.text = ""
        self.clearTextButton.visibility = .gone
        places = []
        tableView.reloadData()
        self.view.endEditing(true)
        self.delegate?.placeSelected(place: nil)
    }
    @IBAction func close(_ sender: Any) {
        self.view.endEditing(true)
        delegate?.close()
    }
    
    var timer: Timer?

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        timer?.invalidate()  // Cancel any previous timer

        // If the textField contains at least 1 characters…
        let currentText = textField.text ?? ""
        if (currentText as NSString).replacingCharacters(in: range, with: string).count > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false){_ in
                print("SEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARCH")
                self.getLocationsFromGoogle()
            }
        } else {
            places = []
            tableView.reloadData()
        }
        
        if textField.text!.count > 0 {
            UIView.animate(withDuration: 0.5) {
                self.clearTextButton.visibility = .visible
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.clearTextButton.visibility = .gone
            }
            self.places = []
            self.tableView.reloadData()
        }
        return true
    }
}

extension PlaceAutocompleteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        cell.label.text = places[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let predictionSelected = places[indexPath.row]
        getPlaceDetailFromGoogle(placeId: predictionSelected.place_id!)
        self.view.endEditing(true)
        self.clearTextButton.visibility = .visible
        places = []
        self.tableView.reloadData()
    }
}

extension PlaceAutocompleteViewController{
    func getLocationsFromGoogle(){
        var urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\( textField.text!)&types=geocode&language=en&key=\(GOOGLE_KEY)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlString)
        guard let endpointUrl = url else { return }
        
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
                let result = try JSONDecoder().decode(PlacesG.self, from: data)
                self.places = result.predictions!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
        task.resume()
    }
    
    func getPlaceDetailFromGoogle(placeId: String){
        guard let endpointUrl = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?input=bar&placeid=\(placeId)&key=\(GOOGLE_KEY)") else { return }
        
        var request = URLRequest(url: endpointUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        textField.text = "Loading..."
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                guard let data = data else {
                return
            }
            do {
                self.selectedPlace = try JSONDecoder().decode(PlaceG.self, from: data)
                DispatchQueue.main.async {
                    self.textField.text = self.selectedPlace?.result?.formatted_address!
                    self.delegate?.placeSelected(place: self.selectedPlace!)
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
        task.resume()
    }
}

class PlacesG: Decodable {
    var predictions: [PredictionG]?
}
class PredictionG: Decodable {
    var description: String?
    var id: String?
    var matched_substrings: [SubStringsG]?
    var place_id: String?
    var reference: String?
    var structured_formatting: FormattingG?
    var terms: [TermG]?
    var types: [String]?
}
class SubStringsG: Decodable{
    var length: Int?
    var offset: Int?
}
class FormattingG: Decodable {
    var main_text: String?
    var main_text_matched_substrings: [SubStringsG]?
    var secondary_text: String?
}
class TermG: Decodable {
    var value: String?
    var offset: Int?
}


class PlaceG: Decodable {
    var html_attributions: [String]?
    var result: ResultG?
}
class ResultG: Decodable {
    var address_components: [AddressComponentG]?
    var adr_address: String?
    var formatted_address: String?
    var geometry: GeometryG?
    var icon: String?
    var id: String?
    var name: String?
    var photos: [FotoG]?
    var place_id: String?
}
class FotoG: Decodable{
    var height: Int?
    var html_attributions: [String]?
    var photo_reference: String?
    var width: Int?
}


