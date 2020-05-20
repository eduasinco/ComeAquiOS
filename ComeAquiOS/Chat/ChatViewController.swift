//
//  ChatViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import Starscream

class ChatViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var serachBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: MyOwnTableView!
    
    var data: [ChatObject] = []
    var dataToIndexPath: [Int: IndexPath] = [:]
    
    var page: Int = 1
    var alreadyFetchingData = false
    var query = "query="
    var ws: WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.delegate = self
        serachBar.delegate = self
        userChats()
        webSocketConnetion()
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

extension ChatViewController: WebSocketDelegate{
    private class SocketObject: Decodable {
        var message: MessageResponseObject?
    }
    private class MessageResponseObject: Decodable {
        var chat: ChatObject?
    }
    func webSocketConnetion(){
        var request = URLRequest(url: URL(string: SERVER + "/ws/unread_messages/\(USER.id!)/")!)
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
                if let ip = dataToIndexPath[mro.chat!.id!] {
                    self.data.remove(at: ip.row)
                    self.data.insert(mro.chat!, at: 0)
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [IndexPath(row:0, section: 0)], with: .automatic)
                        self.tableView.deleteRows(at: [ip], with: .automatic)
                        self.tableView.endUpdates()
                    }
                } else {
                    self.data.insert(mro.chat!, at: 0)
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [IndexPath(row:0, section: 0)], with: .automatic)
                        self.tableView.endUpdates()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        ws?.disconnect()
    }
}