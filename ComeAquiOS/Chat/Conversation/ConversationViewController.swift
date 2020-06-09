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
    
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userImage: URLImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUsername: UILabel!
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
    var chatMessages: [[MessageObject]] = []
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
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        blockView.visibility = .gone
        sendButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (sendMessage)))
        
        NotificationCenter.default.addObserver(
        self,
        selector:#selector(returnToApp),
        name: UIApplication.didBecomeActiveNotification,
        object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadEverything()
    }
    
    func loadEverything() {
        page = 1
        chatMessages = []
        getChatMessages()
        getChatDetail()
        fetchMoreData()
        webSocketConnetion()
    }
    @objc func returnToApp() {
//       page = 1
//       chatMessages = []
//       fetchMoreData()
    }
    
    
    @objc func sendMessage() {
        let message = "{\"message\": \"" + textView.text + "\"," +
            "\"command\": \"new_message\"," +
            "\"from\": \(USER.id!)," +
            "\"to\": \(self.chattingWith.id!)," +
        "\"chatId\": \(self.chat!.id!)}"
        ws!.write(string: message)
        textView.text = ""
        textViewDidChange(textView)
    }
    
    func setView() {
        guard let chat = self.chat else {return}
        self.chattingWith = (USER.id == chat.users![0].id) ? chat.users![1] : chat.users![0]
        userImage.loadImageUsingUrlString(urlString: self.chattingWith.profile_photo)
        userName.text = self.chattingWith.full_name
        userUsername.text = self.chattingWith.username

        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageSelector)))

    }
    @objc private func handleImageSelector() {
        performSegue(withIdentifier: "ProfileSegue", sender: nil)
    }
    
    override func viewWillLayoutSubviews() {
        headerView.dropShadow(radius: 1, opacity: 0.3, height: 1)
    }
    
    @IBAction func unblockUser(_ sender: Any) {
        blockUser(chattingWith.id!, block: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OptionsSegue" {
            let vc = segue.destination as? OptionsPopUpViewController
            if isUserBlocked {
                vc?.options = ["Go to profile", "Unblock user", "Report"]
            } else {
                vc?.options = ["Go to profile", "Block user", "Report"]
            }
            vc?.delegate = self
        } else if segue.identifier == "ProfileSegue" {
            let profileVC = segue.destination as? ProfileViewController
            profileVC?.userId = chattingWith?.id
        }
    }
}

extension ConversationViewController: OptionsPopUpProtocol {
    func optionPressed(_ title: String) {
        switch title {
        case "Unblock user":
            blockUser(chattingWith.id!, block: false)
        case "Block user":
            blockUser(chattingWith.id!, block: true)
        case "Go to profile":
            performSegue(withIdentifier: "ProfileSegue", sender: nil)
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
        var request = URLRequest(url: URL(string: ASYNC_SERVER + "/ws/chat/\(chatId)/")!)
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
                        
                        let first = self.chatMessages.first?.first
                        if let first = first, Date.todayYesterdayWeekDay(isoDateString: message.created_at!) == Date.todayYesterdayWeekDay(isoDateString: first.created_at!) {
                            self.chatMessages[0].insert(message, at: 0)
                            DispatchQueue.main.async {
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        } else {
                            self.chatMessages.insert([message], at: 0)
                            DispatchQueue.main.async {
                                self.tableView.beginUpdates()
                                self.tableView.insertSections(IndexSet(integer: 0), with: .bottom)
                                self.tableView.endUpdates()
                            }
                        }
                    } else {
                        self.chatMessages = [[message]]
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
}

extension ConversationViewController {
    private class ResponseChatObject: Decodable {
        var chat: PlaneChatObject?
        var blocked: Bool?
    }
    func getChatDetail(){
        presentTransparentLoader()
        guard let chatId = self.chatId else {return}
        Server.get("/chat_detail/\(chatId)/"){ data, response, error in
            self.closeTransparentLoader()
            if let _ = error {
                self.holderView.showToast(message: "No internet connection")
            }
            self.alreadyFetchingData = false
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
        }
    }
    func setMessageAsSeen(messageId: Int){
        Server.put("/mark_message_as_seen/\(messageId)/", json: ["":""], finish: {(data: Data?, response: URLResponse?) -> Void in })
    }
    func fetchMoreData(){
        if !alreadyFetchingData {
            getChatMessages()
        }
    }
    
    func groupBadge(badge: [MessageObject]) -> [[MessageObject]] {
        var badgeGrouped = [[MessageObject]]()
        for i in 0..<badge.count {
            if i == 0 || Date.todayYesterdayWeekDay(isoDateString: badge[i].created_at!) != Date.todayYesterdayWeekDay(isoDateString: badge[i - 1].created_at!) {
                let newSection = [badge[i]]
                badgeGrouped.append(newSection)
            } else {
                badgeGrouped[badgeGrouped.count - 1].append(badge[i])
            }
        }
        return badgeGrouped
    }
    
    func getChatMessages(){
        alreadyFetchingData = true
        guard let chatId = self.chatId else {return}
        Server.get("/chat_messages/\(chatId)/\(page)/"){ data, response, error in
            self.alreadyFetchingData = false
            if let _ = error {
                self.holderView.showToast(message: "No internet connection")
            }
            guard let data = data else {return}
            do {
                let messageBadge = try JSONDecoder().decode([MessageObject].self, from: data)
                let chatBadgeGrouped = self.groupBadge(badge: messageBadge)
                let last = self.chatMessages.last?.last
                let first = chatBadgeGrouped.first?.first
                
                if let last = last, let first = first, Date.todayYesterdayWeekDay(isoDateString: last.created_at!) == Date.todayYesterdayWeekDay(isoDateString: first.created_at!) {
                    self.chatMessages[self.chatMessages.count - 1].append(contentsOf: chatBadgeGrouped.first!)
                    self.chatMessages.append(contentsOf: chatBadgeGrouped[1...])
                } else {
                    if chatBadgeGrouped.count > 0, chatBadgeGrouped.first!.count > 0 {
                        self.chatMessages.append(contentsOf: chatBadgeGrouped)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.page += 1
                }
            } catch {}
        }
    }
    func blockUser(_ userId: Int, block: Bool){
        presentTransparentLoader()
        Server.get("/block_user/\(userId)/" + (block ? "block": "unblock") + "/"){ data, response, error in
            self.closeTransparentLoader()
            if let _ = error {
                self.holderView.showToast(message: "No internet connection")
            }
            guard let data = data else {return}
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                if user.is_user_blocked! {
                    DispatchQueue.main.async {
                        self.blockView.visibility = .visible
                        self.view.showToast(message: "User blocked")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.blockView.visibility = .gone
                        self.view.showToast(message: "User unblocked")
                    }
                }
            } catch _ {
                DispatchQueue.main.async {
                    self.view.showToast(message: "Some error ocurred")
                }
            }
        }
    }
}


extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if contentHeight > scrollView.frame.height, offsetY > contentHeight - scrollView.frame.height {
            fetchMoreData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatMessages.count
    }
    
    class DateHeaderLabel: UILabel {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor(named: "PrimaryLight")
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
            let height = originalContentSize.height + 2
            layer.cornerRadius = height / 2
            layer.masksToBounds = true
            return CGSize(width: originalContentSize.width + 20, height: height)
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[section].first {
            let label = DateHeaderLabel()
            label.text = Date.todayYesterdayWeekDay(isoDateString: firstMessageInSection.created_at!)
            label.dropShadow(radius: 1, opacity: 0.3, height: 1)
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
        if chatMessages.count > 0 {
            let chatMessage = chatMessages[indexPath.section][indexPath.row]
            var messageBefore: MessageObject? = nil
            
            if indexPath.row < chatMessages[indexPath.section].count - 1 {
                messageBefore = chatMessages[indexPath.section][indexPath.row + 1]
            }
            
            cell.setCell(message: chatMessage, messageBefore: messageBefore)
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        }
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
            UIView.animate(withDuration: 0.5) {
                self.sendButton.visibility = .visible
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.sendButton.visibility = .goneX
                self.view.layoutIfNeeded()
            }
        }
        return numberOfChars < 200
    }
}
