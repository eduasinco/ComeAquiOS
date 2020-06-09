//
//  GuestingViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 29/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import Starscream

class GuestingViewController: LoadViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGuestingView: UIView!
    
    var orders: [OrderObject] = []
    var ordersToIndexPath: [Int: IndexPath] = [:]
    
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
        orders = []
        page = 1
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
        if orders.count > 0 {
            let order = orders[indexPath.row]
            cell.setCell(order: order)
            ordersToIndexPath[order.id!] = indexPath
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OrderLookSegue", sender: orders[indexPath.row])
    }
}

extension GuestingViewController {
    func getMyGuesting(){
        alreadyFetchingData = true
        tableView.showActivityIndicator()
        Server.get( "/my_guesting/\(page)/"){ data, response, error in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            if let _ = error {
                self.onReload = self.getMyGuesting
                return
            }
            guard let data = data else {return}
            do {
                self.orders.append(contentsOf: try JSONDecoder().decode([OrderObject].self, from: data))
                self.page += 1
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if self.orders.count == 0 {
                        self.noGuestingView.visibility = .visible
                    } else {
                        self.noGuestingView.visibility = .invisible
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
                getMyGuesting()
            }
        }
    }
}

extension GuestingViewController: WebSocketDelegate{
    private class SocketObject: Decodable {
        var message: MessageResponseObject?
    }
    private class MessageResponseObject: Decodable {
        var order_changed: OrderObject?
    }
    func webSocketConnetion(){
        var request = URLRequest(url: URL(string: ASYNC_SERVER + "/ws/orders/\(USER.id!)/")!)
        request.timeoutInterval = 5
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.ws?.connect()
                print("WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEB")
            })
            print("DISCONEETEEEEEEEEEEEEEEEEEEEEEEEEEEEED \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            let data = string.data(using: .utf8)!
            do {
                let so = try JSONDecoder().decode(SocketObject.self, from: data)
                guard let mro = so.message else {return}
                if let ip = ordersToIndexPath[mro.order_changed!.id!] {
                    orders[ip.row] = mro.order_changed!
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.reloadRows(at: [ip], with: .automatic)
                        self.tableView.endUpdates()
                        self.noGuestingView.visibility = .invisible
                    }
                } // else {
//                    orders.insert(mro.order_changed!, at: 0)
//                    DispatchQueue.main.async {
//                        self.tableView.beginUpdates()
//                        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
//                        self.tableView.endUpdates()
//                    }
//                }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.ws?.connect()
                print("WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEB")
            })
            break
        }
    }
}

