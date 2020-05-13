//
//  SearchViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 12/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var people: UIButton!
    @IBOutlet weak var all: UIButton!
    @IBOutlet weak var sort: UIButton!
    @IBOutlet weak var price: UIButton!
    @IBOutlet weak var mealTime: UIButton!
    @IBOutlet weak var distance: UIButton!
    @IBOutlet weak var dietary: UIButton!
    @IBOutlet weak var deleteAll: UIButton!
    @IBOutlet weak var tableView: MyOwnTableView!
    
    var data: [FoodPostObject] = []
    var page: Int = 1
    var alreadyFetchingData = false
    var query = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        getFoodPost()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AllFilterSegue" {
            let vc = segue.destination as? AllViewController
            vc?.delegate = self
        } else if segue.identifier == "SortFilterSegue" {
            let vc = segue.destination as? SortViewController
            vc?.delegate = self
        } else if segue.identifier == "PriceFilterSegue" {
            let vc = segue.destination as? PriceViewController
            vc?.delegate = self
        } else if segue.identifier == "MealTimeFilterSegue" {
            let vc = segue.destination as? MealTimeViewController
            vc?.delegate = self
        } else if segue.identifier == "DistanceFilterSegue" {
            let vc = segue.destination as? DistanceViewController
            vc?.delegate = self
        } else if segue.identifier == "DietaryFilterSegue" {
            let vc = segue.destination as? DietaryViewController
            vc?.delegate = self
        } else if segue.identifier == "PeopleSegue" {
            _ = segue.destination as? PeopleViewController
        } else if segue.identifier == "FoodLookSegue" {
            let vc = segue.destination as? FoodLookViewController
            vc?.foodPostId = (sender as! FoodPostObject).id
        }
    }
}

extension SearchViewController: FilterDelegate {
    func sort(sortType: Int) {
        
    }
    
    func price(price: Int) {
        
    }
    
    func mealTime(startTime: Date, endTime: Date) {
        
    }
    
    func distance(distance: Int) {
        
    }
    
    func dietary(type: String) {
        
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tab1Cell") as! Tab1TableViewCell
        cell.setCell(data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FoodLookSegue", sender: data[indexPath.row])
    }
}
