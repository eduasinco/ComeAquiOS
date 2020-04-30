//
//  HostingViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 29/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class HostingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var foodPosts: [FoodPostObject] = []
    
    var page = 1
    var alreadyFetchingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getMyHostings()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FoodLookSegue" {
            let foodLookVC = segue.destination as? FoodLookViewController
            foodLookVC?.foodPostId = (sender as! FoodPostObject).id
        } else if segue.identifier == "AddFoodSegue" {
            let addFoodVC = segue.destination as? AddFoodViewController
            addFoodVC?.foodPostId = (sender as! FoodPostObject).id
        }
    }
}

extension HostingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostingCell") as! HostingTableViewCell
        cell.setCell(foodPost: foodPosts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let foodPost = foodPosts[indexPath.row]
        if foodPost.visible! {
            performSegue(withIdentifier: "FoodLookSegue", sender: foodPost)
        } else {
            performSegue(withIdentifier: "AddFoodSegue", sender: foodPost)
        }
    }
}

extension HostingViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !alreadyFetchingData {
                getMyHostings()
            }
        }
    }
    func getMyHostings(){
        alreadyFetchingData = true
        Server.get( "/my_hosting/\(page)/", finish: {(data: Data?) -> Void in
            guard let data = data else {return}
            do {
                self.foodPosts.append(contentsOf: try JSONDecoder().decode([FoodPostObject].self, from: data))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.page += 1
                }
            } catch {}
        }, error: {(data: Data?) -> Void in})
    }
}

