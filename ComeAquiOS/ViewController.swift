//
//  ViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UITabBarController {
    
    var ws: WebSocket?
    @IBOutlet weak var myTabbar: UITabBar!
    var mapViewController: MapViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        webSocketConnetion()
        mapViewController = self.viewControllers![0].childForScreenEdgesDeferringSystemGestures as? MapViewController
        myTabbar.items?[0].title = ""
        myTabbar.items?[1].title = ""
        myTabbar.items?[2].title = ""
        myTabbar.items?[3].title = ""
    }
}

extension ViewController: WebSocketDelegate {
    private class SocketObject: Decodable {
        var message: MessageResponseObject?
    }
    private class MessageResponseObject: Decodable {
        var notifications_not_seen: Int?
        var messages_not_seen: Int?
        var orders_not_seen: Int?
    }
    func webSocketConnetion(){
        var request = URLRequest(url: URL(string: SERVER + "/ws/popups/\(USER.id!)/")!)
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
                if let notiNotSeen = mro.notifications_not_seen {
                    if notiNotSeen > 0 {
                        if let tabItems = myTabbar.items {
                            let tabItem = tabItems[2]
                            tabItem.badgeValue = "\(notiNotSeen)"
                        }
                    } else {
                        if let tabItems = myTabbar.items {
                            let tabItem = tabItems[2]
                            tabItem.badgeValue = nil
                        }
                    }
                }
                if let unseenMessages = mro.messages_not_seen {
                    if unseenMessages > 0 {
                        mapViewController?.navigationItem.rightBarButtonItem?.addBadge(number: unseenMessages)
                    } else {
                        mapViewController?.navigationItem.rightBarButtonItem?.removeBadge()
                    }
                }
                if let ordersNotSeen = mro.orders_not_seen {
                    if ordersNotSeen > 0 {
                        if let tabItems = myTabbar.items {
                            let tabItem = tabItems[1]
                            tabItem.badgeValue = "\(ordersNotSeen)"
                        }
                    } else {
                        if let tabItems = myTabbar.items {
                            let tabItem = tabItems[1]
                            tabItem.badgeValue = nil
                        }
                    }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.ws?.connect()
                print("WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEB")
            })
            break
        }
    }
}

