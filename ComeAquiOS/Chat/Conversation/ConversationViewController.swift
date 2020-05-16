//
//  ConversationViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ConversationViewController: KUIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!

    var messagesFromServer: [MessageObject] = []
    var chatId: Int?
    var chatMessages = [[MessageObject]]()
    var page: Int = 1
    var alreadyFetchingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = bottomViewConstraint
        scrollView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        textView.isScrollEnabled = true
        sendButton.visibility = .goneX
        getChatDetail()
        getChatMessages()
    }
    @IBAction func send(_ sender: Any) {
    }
}
extension ConversationViewController {
    private class ResponseFoodPostObject: Decodable{
        var chat: ChatObject?
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
                _ = try JSONDecoder().decode(ResponseFoodPostObject.self, from: data)
                DispatchQueue.main.async {
                }
            } catch {}
        })
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
                self.messagesFromServer.append(contentsOf: try JSONDecoder().decode([MessageObject].self, from: data))
                DispatchQueue.main.async {
                    self.attemptToAssembleGroupedMessages()
                    self.tableView.reloadData()
                    self.page += 1
                }
            } catch {}
        })
    }
    func blockOrUnblockUser(userId: Int){
        self.tableView.showActivityIndicator()
        Server.get("/block_user/\(userId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            self.alreadyFetchingData = false
            self.tableView.hideActivityIndicator()
            guard let data = data else {return}
            do {
                _ = try JSONDecoder().decode(ResponseFoodPostObject.self, from: data)
                DispatchQueue.main.async {
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let firstMessageInSection = chatMessages[section].first {
            return firstMessageInSection.created_at
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


class YourViewController: KUIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
    }
}
extension YourViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}
