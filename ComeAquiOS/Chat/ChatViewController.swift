//
//  ChatViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import Starscream

class ChatViewController: KUIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var serachBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: MyOwnTableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var noMessagesView: UIView!
    
    var data: [ChatObject] = []
    var chatSet: Set<Int> = []
    
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
        self.bottomConstraintForKeyboard = bottomConstraint
        webSocketConnetion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        data = []
        page = 1
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
        presentTransparentLoader()
        self.tableView.showActivityIndicator()
        query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Server.get("/my_chats/" + query + "/\(page)/"){ data, response, error in
            self.alreadyFetchingData = false
            if let _ = error {
                self.onReload = self.userChats
            }
            self.closeTransparentLoader()
            self.tableView.hideActivityIndicator()
            guard let data = data else {return}
            do {
                let chatLoad = try JSONDecoder().decode([ChatObject].self, from: data)
                self.data.append(contentsOf: chatLoad)
                DispatchQueue.main.async {
                    for chat in chatLoad {
                        self.chatSet.insert(chat.id!)
                    }
                    self.tableView.reloadData()
                    self.page += 1
                    if self.data.count == 0 {
                        self.noMessagesView.visibility = .visible
                    } else {
                        self.noMessagesView.visibility = .invisible
                    }
                }
            } catch {}
        }
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
        if data.count > 0 {
            cell.setCell(chat: data[indexPath.row])
        }
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
        var request = URLRequest(url: URL(string: ASYNC_SERVER + "/unread_messages/\(USER.id!)/")!)
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
        case .disconnected(let reason, let code):
            // isConnected = false
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//                self.ws?.connect()
//                print("========================================")
//            })
            break
        case .text(let string):
            print("Received text: \(string)")
            let data = string.data(using: .utf8)!
            do {
                let so = try JSONDecoder().decode(SocketObject.self, from: data)
                guard let mro = so.message else {return}
                if chatSet.contains(mro.chat!.id!) {
                    moveChatToFirstPosition(mro.chat!)
                } else {
                    self.data.insert(mro.chat!, at: 0)
                    chatSet.insert(mro.chat!.id!)
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [IndexPath(row:0, section: 0)], with: .automatic)
                        self.tableView.endUpdates()
                        self.noMessagesView.visibility = .invisible
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
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//                self.ws?.connect()
//                print("========================================")
//            })
            break
        }
    }
    
    func findChatIndex(_ chatId: Int) -> Int? {
        var  i = 0
        while i < data.count && data[i].id != chatId {
            i += 1
        }
        guard i < data.count else {return nil}
        return i
    }
    
    func moveChatToFirstPosition(_ chat: ChatObject) {
        guard let i = findChatIndex(chat.id!) else {return}
        self.data.remove(at: i)
        self.data.insert(chat, at: 0)
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            self.tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .fade)
            self.tableView.endUpdates()
        }
    }
}
