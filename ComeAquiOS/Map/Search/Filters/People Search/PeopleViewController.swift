//
//  PeopleViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: MyOwnTableView!
    
    var data: [User] = []
    var page: Int = 1
    var alreadyFetchingData = false
    var query = "query="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        scrollView.delegate = self
        search.delegate = self
        userSearch()
    }
    
    var timer: Timer?
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()  // Cancel any previous timer

        // If the textField contains at least 1 characters…
        self.query = "query=" + searchText
        if searchText.count > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false){_ in
                self.page = 1
                self.data = []
                self.fetchMoreData()
            }
        } else {
            self.page = 1
            self.data = []
            self.fetchMoreData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchText \(searchBar.text!)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileSegue" {
            let profileVC = segue.destination as? ProfileViewController
            profileVC?.userId = (sender as? User)!.id
        }
    }
}

extension PeopleViewController {
    func fetchMoreData(){
        if !alreadyFetchingData {
            userSearch()
        }
    }
    func userSearch(){
        alreadyFetchingData = true
        self.tableView.showActivityIndicator()
        query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Server.get("/user_search/" + query + "&page=\(page)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            guard let data = data else {return}
            do {
                self.data.append(contentsOf: try JSONDecoder().decode([User].self, from: data))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.page += 1
                }
            } catch {}
        })
    }
}

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            fetchMoreData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! PeopleTableViewCell
        cell.setCell(user: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ProfileSegue", sender: data[indexPath.row])
    }
}
