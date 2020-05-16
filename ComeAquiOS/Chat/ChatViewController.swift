//
//  ChatViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var serachBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: MyOwnTableView!
    
    var data: [ChatObject] = []
    var page: Int = 1
    var alreadyFetchingData = false
    var query = "query="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.delegate = self
        serachBar.delegate = self
        userChats()
    }
    
    var timer: Timer?
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()  // Cancel any previous timer
        
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
        if segue.identifier == "ConversationSegue" {
            let vc = segue.destination as? ConversationViewController
            vc?.chatId = (sender as? ChatObject)!.id
        }
    }
}

extension ChatViewController {
    func fetchMoreData(){
        if !alreadyFetchingData {
            userChats()
        }
    }
    func userChats(){
        alreadyFetchingData = true
        self.tableView.showActivityIndicator()
        query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Server.get("/my_chats/" + query + "/\(page)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            guard let data = data else {return}
            do {
                self.data.append(contentsOf: try JSONDecoder().decode([ChatObject].self, from: data))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.page += 1
                }
            } catch {}
        })
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatTableViewCell
        cell.setCell(chat: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ConversationSegue", sender: data[indexPath.row])
    }
}
