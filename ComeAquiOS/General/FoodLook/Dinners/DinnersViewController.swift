//
//  DinnersViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 19/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class DinnersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var orders: [OrderObject] = []
    var foodPostId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        getOrders()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension DinnersViewController {
    func getOrders(){
        var request = getRequestWithAuth("/foods/\(foodPostId!)/")
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            guard let data = data else {
                return
            }
            do {
                let foodPost = try JSONDecoder().decode(FoodPostObject.self, from: data)
                self.orders.append(contentsOf: foodPost.confirmed_orders!)
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            } catch {
            }
        })
        task.resume()
    }
}

extension DinnersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CommentsTableViewCell", owner: self, options: nil)?.first as! DinnerTableViewCell
        cell.setCell(order: orders[indexPath.row])
        return cell
    }
}
