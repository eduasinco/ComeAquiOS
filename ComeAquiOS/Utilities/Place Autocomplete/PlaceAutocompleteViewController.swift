//
//  PlaceAutocompleteViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 20/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class PlaceAutocompleteViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var tableView: MyOwnTableView!
    var places: [PredictionG] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        // tableView.isScrollEnabled = false
        
        textView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        getLocationsFromGoogle()
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
}

extension PlaceAutocompleteViewController{
    func getLocationsFromGoogle(){
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\( textView.text!)&types=geocode&language=en&key=\(GOOGLE_KEY)")
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
            } catch let jsonErr {
                print("json could'nt be parsed \(jsonErr)")
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

