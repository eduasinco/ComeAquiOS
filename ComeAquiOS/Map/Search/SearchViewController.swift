//
//  SearchViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 12/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchViewController: KUIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var people: UIButton!
    @IBOutlet weak var all: UIButton!
    @IBOutlet weak var sort: UIButton!
    @IBOutlet weak var price: UIButton!
    @IBOutlet weak var mealTime: UIButton!
    @IBOutlet weak var distance: UIButton!
    @IBOutlet weak var dietary: UIButton!
    @IBOutlet weak var deleteAll: UIButton!
    @IBOutlet weak var tableView: MyOwnTableView!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topHeaderConstraint: NSLayoutConstraint!
    @IBOutlet weak var shortHeaderView: UIScrollView!
    
    var data: [FoodPostObject] = []
    var page: Int = 1
    var alreadyFetchingData = false
    
    var DISTANCE: Double = 1000
    var globalDistance: Double = 1000
    var initialLocation: CLLocation? {
        didSet{
            self.location = initialLocation
        }
    }
    var autocompleteVC: PlaceAutocompleteViewController?
    var location: CLLocation?
    var sortValue: Int?
    var priceValue: Int?
    var startTimeValue: String?
    var endTimeValue: String?
    var dietaryValue: String?
    var query = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.bottomConstraintForKeyboard = viewBottomConstraint
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableTopConstraint.constant = headerView.frame.height
        scrollView.delegate = self
        getFoodPost()
    }
    
    func setDistanceQuery(){
        let top = location?.movedBy(latitudinalMeters: 0, longitudinalMeters: globalDistance).coordinate.longitude
        let right = location?.movedBy(latitudinalMeters: globalDistance, longitudinalMeters: 0).coordinate.latitude
        let bottom = location?.movedBy(latitudinalMeters: 0, longitudinalMeters: -globalDistance).coordinate.longitude
        let left = location?.movedBy(latitudinalMeters: -globalDistance, longitudinalMeters: 0).coordinate.latitude

        query = "distance=\(right!),\(top!),\(left!),\(bottom!)"
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        location = initialLocation
        globalDistance = DISTANCE
        autocompleteVC?.textField.text = nil
        sortValue = nil
        priceValue = nil
        startTimeValue = nil
        endTimeValue = nil
        dietaryValue = nil
        self.page = 1
        self.data = []
        getFoodPost()
    }
    
    func createQuery(){
        setDistanceQuery()
        if let sortValue = sortValue {
            query += "&sort=\(sortValue)"
            sort.backgroundColor = UIColor.black
        } else {
            sort.backgroundColor = UIColor.white
        }
        if let priceValue = priceValue {
            query += "&price=\(priceValue)"
            price.backgroundColor = UIColor.black
        } else {
            price.backgroundColor = UIColor.white
        }
        if let startTimeValue = startTimeValue, let endTimeValue = endTimeValue {
            query += "&start_date=\(startTimeValue)"
            query += "&end_date=\(endTimeValue)"
            mealTime.backgroundColor = UIColor.black
        } else {
            mealTime.backgroundColor = UIColor.white
        }
        if globalDistance == DISTANCE {
            distance.backgroundColor = UIColor.white
        } else {
            distance.backgroundColor = UIColor.black
        }
        if let dietaryValue = dietaryValue {
            query += "&dietary=\(dietaryValue)"
            dietary.backgroundColor = UIColor.black
        } else {
            dietary.backgroundColor = UIColor.white
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaceAutocompleteSegue" {
            autocompleteVC = segue.destination as? PlaceAutocompleteViewController
            autocompleteVC?.delegate = self
        } else if segue.identifier == "AllFilterSegue" {
            let vc = segue.destination as? AllViewController
            vc?.delegate = self
        } else if segue.identifier == "SortFilterSegue" {
            let vc = segue.destination as? SortViewController
            vc?.delegate = self
            vc?.sortType = sortValue ?? 0
        } else if segue.identifier == "PriceFilterSegue" {
            let vc = segue.destination as? PriceViewController
            vc?.delegate = self
            vc?.priceType = priceValue ?? 2
        } else if segue.identifier == "MealTimeFilterSegue" {
            let vc = segue.destination as? MealTimeViewController
            vc?.delegate = self
            
        } else if segue.identifier == "DistanceFilterSegue" {
            let vc = segue.destination as? DistanceViewController
            vc?.delegate = self
            vc?.distance = Int(globalDistance)
        } else if segue.identifier == "DietaryFilterSegue" {
            let vc = segue.destination as? DietaryViewController
            vc?.delegate = self
            vc?.type = dietaryValue ?? "0000000"
        } else if segue.identifier == "PeopleSegue" {
            _ = segue.destination as? PeopleViewController
        } else if segue.identifier == "FoodLookSegue" {
            let vc = segue.destination as? FoodLookViewController
            vc?.foodPostId = (sender as! FoodPostObject).id
        }
    }
}

extension SearchViewController: FilterDelegate, AutocompleteProtocol {
    func close() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func placeSelected(place: PlaceG?) {
        headerView.layoutIfNeeded()
        tableTopConstraint.constant = headerView.frame.height
        guard let place = place else {return}
        self.location = CLLocation(latitude: (place.result?.geometry?.location?.lat)!, longitude: (place.result?.geometry?.location?.lng)!)
        self.page = 1
        self.data = []
        getFoodPost()
    }
    
    func sort(sortType: Int) {
        sortValue = sortType
        self.page = 1
        self.data = []
        getFoodPost()
    }
    
    func price(price: Int) {
        priceValue = price
        self.page = 1
        self.data = []
        getFoodPost()
    }
    
    func mealTime(startTime: String, endTime: String) {
        startTimeValue = startTime
        endTimeValue = endTime
        self.page = 1
        self.data = []
        getFoodPost()
    }
    
    func distance(distance: Int) {
        globalDistance = Double(distance)
        setDistanceQuery()
        self.page = 1
        self.data = []
        getFoodPost()
    }
    
    func dietary(type: String) {
        dietaryValue = type
        self.page = 1
        self.data = []
        getFoodPost()
    }
}

extension SearchViewController {
    func fetchMoreData(){
        if !alreadyFetchingData {
            getFoodPost()
        }
    }
    func getFoodPost(){
        alreadyFetchingData = true
        createQuery()
        self.tableView.showActivityIndicator()
        Server.get("/food_query/" + query + "&page=\(page)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            guard let data = data else {return}
            do {
                self.data.append(contentsOf: try JSONDecoder().decode([FoodPostObject].self, from: data))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.page += 1
                }
            } catch {}
        })
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let d = headerView.frame.height - shortHeaderView.frame.height
        if scrollView.contentOffset.y >= d {
            topHeaderConstraint.constant = -d
            headerView.dropShadow(radius: 1, opacity: 1)
        } else {
            topHeaderConstraint.constant = -scrollView.contentOffset.y
            headerView.dropShadow()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! Tab1TableViewCell
        cell.setCell(data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FoodLookSegue", sender: data[indexPath.row])
    }
}
