//
//  HostingViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 29/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class HostingViewController: LoadViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notHostingView: UIView!
    var foodPosts: [FoodPostObject] = []
    
    var page = 1
    var alreadyFetchingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        foodPosts = []
        page = 1
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
        if foodPosts.count > 0 {
            cell.setCell(foodPost: foodPosts[indexPath.row])
        }
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
        
        if contentHeight > scrollView.frame.height, offsetY > contentHeight - scrollView.frame.height {
            if !alreadyFetchingData {
                getMyHostings()
            }
        }
    }
    func getMyHostings(){
        alreadyFetchingData = true
        tableView.showActivityIndicator()
        Server.get( "/my_hosting/\(page)/"){ data, response, error in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            if let _ = error {
                self.onReload = self.getMyHostings
                return
            }
            guard let data = data else {return}
            do {
                self.foodPosts.append(contentsOf: try JSONDecoder().decode([FoodPostObject].self, from: data))
                self.page += 1
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if self.foodPosts.count == 0 {
                        self.notHostingView.visibility = .visible
                    } else {
                        self.notHostingView.visibility = .invisible
                    }
                }
            } catch {}
        }
    }
}

