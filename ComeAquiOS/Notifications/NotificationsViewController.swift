//
//  NotificationsViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class NotificationsViewController: LoadViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var notifications: [NotificationObject] = []
    
    var page = 1
    var alreadyFetchingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        page = 1
        notifications = []
        getMyNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FoodLookSegue" {
            let foodLookVC = segue.destination as? FoodLookViewController
            foodLookVC?.foodPostId = (sender as! NotificationObject).type_id
        } else if segue.identifier == "OrderLookSegue" {
            let orderVC = segue.destination as? OrderLookViewController
            orderVC?.orderId = (sender as! NotificationObject).type_id
        } else if segue.identifier == "NotificationLookSegue" {
            let foodLookVC = segue.destination as? FoodLookViewController
            foodLookVC?.foodPostId = (sender as! NotificationObject).type_id
        } else if segue.identifier == "OrderLookSegue" {
            let orderVC = segue.destination as? OrderLookViewController
            orderVC?.orderId = (sender as! NotificationObject).type_id
        } else if segue.identifier == "FoodReviewSegue" {
            let foodRVC = segue.destination as? FoodReviewLookViewController
            foodRVC?.foodPostId = (sender as! NotificationObject).type_id
        }
    }
}

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationTableViewCell
        cell.setCell(notification: notifications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        switch notification.type {
        case "PENDING":
            performSegue(withIdentifier: "OrderLookSegue", sender: notification)
            break
        case "CONFIRMED":
            performSegue(withIdentifier: "OrderLookSegue", sender: notification)
            break
        case "REJECTED":
            break
        case "CANCELED":
            performSegue(withIdentifier: "OrderLookSegue", sender: notification)
            break
        case "REVIEW":
            performSegue(withIdentifier: "FoodReviewSegue", sender: notification)
            break
        case "COMMENT":
            performSegue(withIdentifier: "FoodLookSegue", sender: notification)
            break
        case "INFO":
            break
        default:
            break
        }
    }
}

extension NotificationsViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !alreadyFetchingData {
                getMyNotifications()
            }
        }
    }
    func getMyNotifications(){
        alreadyFetchingData = true
        if !self.alert.isBeingDismissed {
            self.alert.dismiss(animated: false, completion: nil)
        }
        present(alert, animated: false, completion: nil)
        Server.get("/my_notifications/\(page)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                if !self.alert.isBeingDismissed {
                    self.alert.dismiss(animated: false, completion: nil)
                }
            }
            guard let data = data else {return}
            do {
                self.notifications.append(contentsOf: try JSONDecoder().decode([NotificationObject].self, from: data))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.page += 1
                    self.alreadyFetchingData = false
                }
            } catch {}
        })
    }
}

