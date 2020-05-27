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
        tableView.dataSource = self
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileSegue" {
            let vc = segue.destination as? ProfileViewController
            vc?.userId = (sender as? User)?.id
        } else if segue.identifier == "ConversationSegue" {
            let vc = segue.destination as? ConversationViewController
            vc?.chatId = sender as? Int
        }
    }
}
extension DinnersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DinnerTableViewCell") as! DinnerTableViewCell
        cell.setCell(order: orders[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ProfileSegue", sender: orders[indexPath.row].owner)
    }
}

extension DinnersViewController: DinnderCellDelegate {
    func chatButtonPressed(order: OrderObject) {
        getConversation(withUser: order.owner!)
    }
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
    
    func getConversation(withUser: User){
        Server.get("/get_or_create_chat/\(withUser.id!)/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                
            }
            guard let data = data else {
                return
            }
            do {
                let chat = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "ConversationSegue", sender: chat.id)
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
    }
}
