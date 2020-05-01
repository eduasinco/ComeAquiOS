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
    }
    override func viewWillAppear(_ animated: Bool) {
        page = 1
        orders = []
        getMyGuesting()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OrderLookSegue" {
            let orderLookVC = segue.destination as? OrderLookViewController
            orderLookVC?.orderId = (sender as! OrderObject).id
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OrderLookSegue", sender: orders[indexPath.row])
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
        Server.get( "/my_guesting/\(page)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            guard let data = data else {return}
            do {
                self.orders.append(contentsOf: try JSONDecoder().decode([OrderObject].self, from: data))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {}
        })
    }
}

