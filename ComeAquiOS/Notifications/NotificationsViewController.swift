//
//  NotificationsViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import Starscream

class NotificationsViewController: LoadViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var notifications: [NotificationObject] = []
    var notificationToIndexPath: [String: IndexPath] = [:]
    @IBOutlet weak var noNotificationsView: UIView!
    
    var page = 1
    var alreadyFetchingData = false
    var ws: WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        webSocketConnetion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        notifications = []
        page = 1
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
        if notifications.count > 0 {
            let notification = notifications[indexPath.row]
            cell.setCell(notification: notification)
            notificationToIndexPath[notification._id!] = indexPath
        }
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
            performSegue(withIdentifier: "OrderLookSegue", sender: notification)
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
    func getMyNotifications(){
        alreadyFetchingData = true
        Server.get("/my_notifications/\(page)/"){ data, response, error in
            self.alreadyFetchingData = false
            if let _ = error {
                self.onReload = self.getMyNotifications
            }
            guard let data = data else {return}
            do {
                let newNotifications = try JSONDecoder().decode([NotificationObject].self, from: data)
                self.notifications.append(contentsOf: newNotifications)
                self.page += 1
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if self.notifications.count == 0 {
                        self.noNotificationsView.visibility = .visible
                    } else {
                        self.noNotificationsView.visibility = .invisible
                    }
                }
            } catch {}
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if contentHeight > scrollView.frame.height, offsetY > contentHeight - scrollView.frame.height {
            if !alreadyFetchingData {
                getMyNotifications()
            }
        }
    }
}

extension NotificationsViewController: WebSocketDelegate{
    private class SocketObject: Decodable {
        var message: MessageResponseObject?
    }
    private class MessageResponseObject: Decodable {
        var notification_added: NotificationObject?
    }
    func webSocketConnetion(){
        var request = URLRequest(url: URL(string: ASYNC_SERVER + "/notifications/\(USER._id!)/")!)
        request.timeoutInterval = TIME_OUT
        ws = WebSocket(request: request)
        ws?.delegate = self
        ws?.connect()
    }
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            // isConnected = true
            print("CONEETEEEEEEEEEEEEEEEEEEEEEEEEEEEED")
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            // isConnected = false
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//                self.ws?.connect()
//                print("WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEB")
//            })
//            print("DISCONEETEEEEEEEEEEEEEEEEEEEEEEEEEEEED \(reason) with code: \(code)")
            break
        case .text(let string):
            print("Received text: \(string)")
            let data = string.data(using: .utf8)!
            do {
                let so = try JSONDecoder().decode(SocketObject.self, from: data)
                guard let mro = so.message else {return}
                notifications.insert(mro.notification_added!, at: 0)
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                    self.noNotificationsView.visibility = .invisible

                }
            } catch let error as NSError {
                print(error)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            // isConnected = false
            break
        case .error(let error):
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//                self.ws?.connect()
//                print("WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEB")
//            })
            break
        }
    }
}

