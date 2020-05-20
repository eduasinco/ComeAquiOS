//
//  ConversationViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import Starscream

class ConversationViewController: KUIViewController {
    
    @IBOutlet weak var userImage: URLImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockView: UIView!
    
    var messagesFromServer: [MessageObject] = []
    var chatId: Int?
    var chat: PlaneChatObject?
    var isUserBlocked: Bool = false
    var chattingWith: User!
    var chatMessages = [[MessageObject]]()
    var page: Int = 1
    var alreadyFetchingData = false
    
    var ws: WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = bottomViewConstraint
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        textView.isScrollEnabled = true
        sendButton.visibility = .goneX
        getChatDetail()
        getChatMessages()
        webSocketConnetion()
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        blockView.visibility = .gone
    }
    
    func setView() {
        guard let chat = self.chat else {return}
        self.chattingWith = (USER.id == chat.users![0].id) ? chat.users![1] : chat.users![0]
        userImage.loadImageUsingUrlString(urlString: self.chattingWith.profile_photo!)
        userName.text = self.chattingWith.full_name
    }
    
    @IBAction func send(_ sender: Any) {
        let message = "{\"message\": \"" + textView.text + "\"," +
            "\"command\": \"new_message\"," +
            "\"from\": \(USER.id!)," +
            "\"to\": \(self.chattingWith.id!)," +
        "\"chatId\": \(self.chat!.id!)}"
        ws!.write(string: message)
        textView.text = ""
        textViewDidChange(textView)
    }
    @IBAction func unblockUser(_ sender: Any) {
        unBlockUser(userId: chattingWith.id!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OptionsSegue" {
            let vc = segue.destination as? OptionsPopUpViewController
            if isUserBlocked {
                vc?.options = ["Unblock user", "Report"]
            } else {
                vc?.options = ["Block user", "Report"]
            }
            vc?.delegate = self
        }
    }
}

extension ConversationViewController: OptionsPopUpProtocol {
    func optionPressed(_ title: String) {
        switch title {
        case "Unblock user":
            unBlockUser(userId: chattingWith.id!)
        case "Block user":
            blockUser(userId: chattingWith.id!)
        case "Report":
            break
        default:
            break
        }
    }
}

extension ConversationViewController: WebSocketDelegate{
    private class SocketObject: Decodable {
        var message: MessageResponseObject?
    }
    private class MessageResponseObject: Decodable {
        var error_message: String?
        var message: MessageObject?
    }
    func webSocketConnetion(){
        guard let chatId = self.chatId else {return}
        var request = URLRequest(url: URL(string: SERVER + "/ws/chat/\(chatId)/")!)
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
                if mro.error_message == nil {
                    guard let message = mro.message else {return}
                    if self.chatMessages.count > 0 {
                        self.chatMessages[0].insert(message, at: 0)
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                        }
                    } else {
                        self.messagesFromServer = [message]
                        self.attemptToAssembleGroupedMessages()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    if message.sender!.id! != USER.id {
                        setMessageAsSeen(messageId: message.id!)
                    }
                } else {
                    
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

extension ConversationViewController {
    private class ResponseChatObject: Decodable {
        var chat: PlaneChatObject?
        var blocked: Bool?
    }
    func getChatDetail(){
        self.tableView.showActivityIndicator()
        guard let chatId = self.chatId else {return}
        Server.get("/chat_detail/\(chatId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            guard let data = data else {return}
            do {
                let responseO = try JSONDecoder().decode(ResponseChatObject.self, from: data)
                self.chat = responseO.chat
                self.isUserBlocked = responseO.blocked!
                DispatchQueue.main.async {
                    self.setView()
                    if self.isUserBlocked {
                        self.blockView.visibility = .visible
                    }
                }
            } catch {
                
            }
        })
    }
    func setMessageAsSeen(messageId: Int){
        Server.put("/mark_message_as_seen/\(messageId)/", json: ["":""], finish: {(data: Data?, response: URLResponse?) -> Void in })
    }
    func fetchMoreData(){
        if !alreadyFetchingData {
            getChatMessages()
        }
    }
    func getChatMessages(){
        alreadyFetchingData = true
        self.tableView.showActivityIndicator()
        guard let chatId = self.chatId else {return}
        Server.get("/chat_messages/\(chatId)/\(page)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            guard let data = data else {return}
            do {
                self.messagesFromServer = try JSONDecoder().decode([MessageObject].self, from: data)
                DispatchQueue.main.async {
                    self.attemptToAssembleGroupedMessages()
                    self.tableView.reloadData()
                    self.page += 1
                }
            } catch {}
        })
    }
    func blockUser(userId: Int){
        self.tableView.showActivityIndicator()
        guard !self.alreadyFetchingData else { return }
        self.alreadyFetchingData = true
        Server.get("/block_user/\(userId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            guard let data = data else {return}
            do {
                _ = try JSONDecoder().decode(User.self, from: data)
                self.isUserBlocked = true
                DispatchQueue.main.async {
                    self.blockView.visibility = .visible
                }
            } catch {}
        })
    }
    func unBlockUser(userId: Int){
        self.tableView.showActivityIndicator()
        guard !self.alreadyFetchingData else { return }
        self.alreadyFetchingData = true
        Server.delete("/block_user/\(userId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            guard let data = data else {return}
            do {
                self.isUserBlocked = false
                DispatchQueue.main.async {
                    self.blockView.visibility = .gone
                }
            } catch {}
        })
    }
}


extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            fetchMoreData()
        }
    }
    
    fileprivate func attemptToAssembleGroupedMessages() {
        print("Attempt to group our messages together based on Date property")
        
        let groupedMessages = Dictionary(grouping: messagesFromServer) { (element) -> String in
            return element.created_at![0..<10]
        }
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            chatMessages.append(values ?? [])
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatMessages.count
    }
    
    class DateHeaderLabel: UILabel {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .black
            textColor = .white
            textAlignment = .center
            translatesAutoresizingMaskIntoConstraints = false // enables auto layout
            font = UIFont.boldSystemFont(ofSize: 14)
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        override var intrinsicContentSize: CGSize {
            let originalContentSize = super.intrinsicContentSize
            let height = originalContentSize.height + 12
            layer.cornerRadius = height / 2
            layer.masksToBounds = true
            return CGSize(width: originalContentSize.width + 20, height: height)
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[section].first {
            let label = DateHeaderLabel()
            label.text = firstMessageInSection.created_at
            let containerView = UIView()

            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

            containerView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            return containerView

        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages[section].count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        let chatMessage = chatMessages[indexPath.section][indexPath.row]
        cell.setCell(message: chatMessage)
        cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        return cell
    }
}


extension ConversationViewController: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        if numberOfChars > 0 {
            sendButton.visibility = .visible
        } else {
            sendButton.visibility = .goneX
        }
        return numberOfChars < 200
    }
}
