//
//  GuestingViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 29/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class GuestingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var orders: [OrderObject] = []
    
    var page = 1
    var alreadyFetchingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getMyGuesting()
    }
}

extension GuestingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuestingCell") as! GuestingTableViewCell
        cell.setCell(order: orders[indexPath.row])
        return cell
    }
}

extension GuestingViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
          if !alreadyFetchingData {
            beginBatchFetched()
          }
        }
    }
    func beginBatchFetched() {
        alreadyFetchingData = true
        getMyGuesting()
    }
    func getMyGuesting(){
        Server.get( "/my_guesting/\(page)/", finish: {(data: Data?) -> Void in
            guard let data = data else {return}
            do {
                self.orders.append(contentsOf: try JSONDecoder().decode([OrderObject].self, from: data))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {}
        }, error: {(data: Data?) -> Void in})
    }
}

