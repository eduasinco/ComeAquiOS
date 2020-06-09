//
//  Tab1ViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 08/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class Tab1ViewController: UIViewController {

    @IBOutlet weak var tableView: MyOwnTableView!
    @IBOutlet weak var noPostsView: UIView!
    
    var data: [FoodPostObject] = []
    var userId : Int? {
        didSet{
            page = 1
            data = []
            self.getUserFoodPost()
        }
    }
    var page: Int = 1
    var alreadyFetchingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FoodLookSegue" {
            let foodLookVC = segue.destination as? FoodLookViewController
            foodLookVC?.foodPostId = (sender as? FoodPostObject)!.id
        }
    }
}
extension Tab1ViewController {
    func fetchMoreData(){
        if !alreadyFetchingData {
            getUserFoodPost()
        }
    }
    func getUserFoodPost(){
        guard let userId = self.userId else {return}
        alreadyFetchingData = true
        self.tableView.showActivityIndicator()
        Server.get("/user_food_posts/\(userId)/\(page)/"){ data, response, error in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            guard let data = data else {return}
            do {
                self.data.append(contentsOf: try JSONDecoder().decode([FoodPostObject].self, from: data))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.page += 1
                    if self.data.count == 0 {
                        self.noPostsView.visibility = .visible
                    } else {
                        self.noPostsView.visibility = .invisible
                    }
                }
            } catch {}
        }
    }
}

extension Tab1ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("PostTableViewCell", owner: self, options: nil)?.first as! PostTableViewCell
        cell.setCell(data[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FoodLookSegue", sender: data[indexPath.row])
    }
}


