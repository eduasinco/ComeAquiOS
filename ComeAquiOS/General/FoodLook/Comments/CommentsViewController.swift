//
//  CommentsViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

let MAX_DEPTH = 3
let MAX_LENGTH = 3
let ACTUAL_DEPTH = 3
let ACTUAL_LENGTH = 3

class Comment {
    var id: Int!
    var ownerId: Int?
    var profile_photo: String?
    var username: String?
    var comment: String!
    var comments: [Comment] = []
    var depth: Int!
    var parent: Comment?
    
    var is_user_upvote = false
    var votes_n: Int!
    var is_last: Bool!
    
    var isMaxDepth = false
    var isMaxLength = 0
        
    init (json: [String: Any], parent: Comment?){
        self.id = json["id"] as? Int
        self.ownerId = (json["owner"] as? [String: Any])?["id"] as? Int
        self.profile_photo = (json["owner"] as? [String: Any])?["profile_photo"] as? String
        self.username = (json["owner"] as? [String: Any])?["username"] as? String
        self.comment = json["message"] as? String
        self.depth = json["depth"] as? Int
        self.votes_n = json["votes_n"] as? Int
        self.is_last = json["is_last"] as? Bool

        self.is_user_upvote = json["is_user_upvote"] as? Bool ?? false
        self.isMaxDepth = json["is_max_depth"] as? Bool ?? false
        self.parent = parent
        
        if self.isMaxDepth {
            self.isMaxDepth = false
            self.comments.append(Comment(parent: self))
        }
        
        for c in json["replies"] as! [Any] {
            if let n = c as? Int {
                self.comments.append(Comment(parent: self, maxLength: n))
            } else {
                self.comments.append(Comment(json: c as! [String: Any], parent: self))
            }
        }
    }
    
    init(parent: Comment, maxLength: Int) {
        self.comment = ""
        self.parent = parent
        self.id = parent.id
        self.depth = parent.depth + 1
        self.isMaxLength = maxLength
    }
    
    init(parent: Comment) {
        self.comment = ""
        self.parent = parent
        self.depth = parent.depth + 1
        self.isMaxDepth = true
    }
}


class CommentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    var _currentlyDisplayed: [Comment] = []
    var makeExpandedCellsVisible: Bool = true
    var currentCell: UITableViewCell?
    var currentComment: Comment?
    var comments: [Comment] = []
    
    var foodPostId: Int? {
        didSet {
            getComments()
        }
    }
    var commentId: Int? {
        didSet {
            getComments()
        }
    }
    var max_depth = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }
    func randomString() -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyz        "
        let mayus: NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
         let len = UInt32(letters.length)
         let len2 = UInt32(mayus.length)

        var randomString = ""
        let rand = arc4random_uniform(len2)
        var nextChar = mayus.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
        
        for _ in 0 ..< Int(arc4random_uniform(200)) {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
    
    func linearizeAllComments(_ comments: [Comment]){
        var q: [Comment] = []
        for c in comments.reversed(){
            q.append(c)
        }
        while q.count > 0 {
            let c = q.popLast()
            _currentlyDisplayed.append(c!)
            for c in c!.comments.reversed(){
                q.append(c)
            }
        }
    }
    
    func linearizeComments(_ comments: [Comment]) -> [Comment] {
        var q: [Comment] = []
        for c in comments.reversed(){
            q.append(c)
        }
        var linearizedComments: [Comment] = []
        while q.count > 0 {
            let c = q.popLast()
            linearizedComments.append(c!)
            for c in c!.comments.reversed(){
                q.append(c)
            }
        }
        return linearizedComments
    }
    
    func subCommentsLinearized(_ comments: [Comment]) -> [Comment]{
        var q: [Comment] = []
        for c in comments.reversed(){
            q.append(c)
        }
        var linearizedComments: [Comment] = []
        while q.count > 0 {
            let c = q.popLast()
            linearizedComments.append(c!)
            for c in c!.comments.reversed(){
                q.append(c)
            }
        }
        return linearizedComments
    }
}
extension CommentsViewController: AddCommentDelegate {
    
    func commentAddedToPost(newComment: Comment) {
        self.comments.insert(newComment, at: 0)
        self._currentlyDisplayed.insert(newComment, at: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
        self.tableView.endUpdates()
    }
    
    func commentAdded(newComment: Comment) {
        let ip = self.tableView.indexPath(for: currentCell!)
        guard let indexPath = ip else { return }
        let selectedCom: Comment = _currentlyDisplayed[indexPath.row]
        let selectedIndex = indexPath.row

        // Do whatever you want from your button here.
        if !(self.isCellExpanded(indexPath: indexPath)){
            // expand
            var toShow: [Comment] = []
            toShow = selectedCom.comments
            self._currentlyDisplayed.insert(contentsOf: toShow, at: selectedIndex+1)
            var indexPaths: [IndexPath] = []
            for i in 0..<toShow.count {
                indexPaths.append(IndexPath(row: selectedIndex+i+1, section: indexPath.section))
            }
            tableView.insertRows(at: indexPaths, with: .bottom)
        } else {
            self._currentlyDisplayed.insert(newComment, at: selectedIndex+1)
            tableView.insertRows(at: [IndexPath(row: selectedIndex+1, section: indexPath.section)], with: .bottom)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToWriteComment"{
            let destVC = segue.destination as! WriteCommentViewController
            destVC.comment = sender as? Comment
            destVC.delegate = self
        } else if segue.identifier == "SelfSegue"{
            let destVC = segue.destination as! SegueViewController
            destVC.commentId = (sender as! Comment).id!
            destVC.max_depth = (sender as! Comment).depth + 1
        } else if segue.identifier == "OptionsSegue"{
            let vc = segue.destination as! OptionsPopUpViewController
            vc.options = ["Report"]
            vc.delegate = self
        }
    }
}

extension CommentsViewController: OptionsPopUpProtocol {
    func optionPressed(_ title: String) {
        switch title {
        case "Report":
            break
        default:
            break
        }
    }
}

extension CommentsViewController: AddOrDeleteDelegate {
    func moreComments(comment: Comment, cell: UITableViewCell) {
        let ip = self.tableView.indexPath(for: cell)
        guard let indexPath = ip else { return }
        let selectedCom: Comment = _currentlyDisplayed[indexPath.row]
        getMoreComments(comment: selectedCom, nLasts: selectedCom.isMaxLength, indexPath: indexPath)
    }
    
    func continueConversation(comment: Comment, cell: CommentsTableViewCell) {
        performSegue(withIdentifier: "SelfSegue", sender: comment.parent!)
    }
    
    func add(comment: Comment, cell: UITableViewCell) {
        self.currentCell = cell
        performSegue(withIdentifier: "goToWriteComment", sender: comment)
    }
    
    func expand(comment: Comment, cell: UITableViewCell) {
        let ip = self.tableView.indexPath(for: cell)
        guard let indexPath = ip else { return }
        let selectedCom: Comment = _currentlyDisplayed[indexPath.row]
        let selectedIndex = indexPath.row

        // Do whatever you want from your button here.
        if !(self.isCellExpanded(indexPath: indexPath)){
            // expand
            var toShow: [Comment] = []
            toShow = self.subCommentsLinearized(selectedCom.comments)
            
            self._currentlyDisplayed.insert(contentsOf: toShow, at: selectedIndex+1)
            var indexPaths: [IndexPath] = []
            for i in 0..<toShow.count {
                indexPaths.append(IndexPath(row: selectedIndex+i+1, section: indexPath.section))
            }
            tableView.insertRows(at: indexPaths, with: .bottom)

            if self.makeExpandedCellsVisible && comment.comments.count > 0 {
                tableView.scrollToRow(at: IndexPath(row: selectedIndex+1, section: indexPath.section), at: UITableView.ScrollPosition.middle, animated: false)
            }
        }
    }

    func collapse(comment: Comment, cell: UITableViewCell) {
        // Do whatever you want from your button here.
        let ip = self.tableView.indexPath(for: cell)
        guard let indexPath = ip else { return }
        let selectedCom: Comment = _currentlyDisplayed[indexPath.row]
        let selectedIndex = indexPath.row

        if self.isCellExpanded(indexPath: indexPath) {
            // collapse
            var nCellsToDelete = 0
            while (_currentlyDisplayed.count > selectedIndex+nCellsToDelete+1 && _currentlyDisplayed[selectedIndex+nCellsToDelete+1].depth > selectedCom.depth){
                nCellsToDelete += 1
            }

            self._currentlyDisplayed.removeSubrange(Range(uncheckedBounds: (lower: selectedIndex+1 , upper: selectedIndex+nCellsToDelete+1)))
            var indexPaths: [IndexPath] = []
            for i in 0..<nCellsToDelete {
                indexPaths.append(IndexPath(row: selectedIndex+i+1, section: indexPath.section))
            }
            tableView.deleteRows(at: indexPaths, with: .bottom)
        }
    }

    func delete(comment: Comment, cell: UITableViewCell) {
        let ip = self.tableView.indexPath(for: cell)
        guard let indexPath = ip else { return }
        deleteComment(comment: comment, indexPath: indexPath)
    }
    
    func options(comment: Comment, cell: UITableViewCell) {
        currentComment = comment
        performSegue(withIdentifier: "OptionsSegue", sender: nil)
    }
    
    func delteComemnt(comment: Comment){
        if let parent = comment.parent {
            for (i, child) in parent.comments.enumerated(){
                if child.id == comment.id {
                    parent.comments.remove(at: i)
                    break
                }
            }
        } else {
            for (i, child) in self.comments.enumerated(){
                if child.id == comment.id {
                    self.comments.remove(at: i)
                    break
                }
            }
        }
    }
}

extension CommentsViewController {
    func getComments(){
        var request: URLRequest
        if let foodPostId = self.foodPostId {
            request = getRequestWithAuth("/food_post_comment/post/\(foodPostId)/")
        } else if let commentId = self.commentId {
            request = getRequestWithAuth("/food_post_comment/comment/\(commentId)/")
        } else { return }
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            guard let data = data else {
                return
            }
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                
                DispatchQueue.main.async {
                    for json in jsonArray as! [[String: Any]]{
                        self.comments.append(Comment(json: json, parent: nil))
                    }
                    self.linearizeAllComments(self.comments)
                    self.tableView.reloadData()
                }
            } catch {
            }
        })
        task.resume()
    }
    
    func deleteComment(comment: Comment, indexPath: IndexPath){
        var request: URLRequest
        request = getRequestWithAuth("/food_post_comment/\(comment.id!)/")
        request.httpMethod = "DELETE"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            guard let _ = data else {return}
            DispatchQueue.main.async {
                let selectedIndex = indexPath.row

                var nCellsToDelete = 0
                while (self._currentlyDisplayed.count > selectedIndex+nCellsToDelete+1 && self._currentlyDisplayed[selectedIndex+nCellsToDelete+1].depth > comment.depth){
                    nCellsToDelete += 1
                }
                self._currentlyDisplayed.removeSubrange(Range(uncheckedBounds: (lower: selectedIndex , upper: selectedIndex+nCellsToDelete+1)))
                var indexPaths: [IndexPath] = []
                for i in 0...nCellsToDelete {
                    indexPaths.append(IndexPath(row: selectedIndex+i, section: indexPath.section))
                }
                self.tableView.deleteRows(at: indexPaths, with: .bottom)
                
                self.delteComemnt(comment: comment)
            }
        })
        task.resume()
    }
    
    func getMoreComments(comment: Comment, nLasts: Int, indexPath: IndexPath){
        var request: URLRequest
        request = getRequestWithAuth("/comment_comments/\(comment.id!)/\(nLasts)/")
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            guard let data = data else {
                return
            }
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                
                DispatchQueue.main.async {
                    let selectedIndex = indexPath.row

                    self._currentlyDisplayed.remove(at: selectedIndex)
                    self.tableView.deleteRows(at: [IndexPath(row: selectedIndex, section: indexPath.section)], with: .bottom)
                    self.delteComemnt(comment: comment)
                    
                    var commentsToAdd: [Comment] = []
                    for json in jsonArray as! [[String: Any]]{
                        commentsToAdd.append(Comment(json: json, parent: comment.parent))
                    }
                    comment.parent!.comments.append(contentsOf: commentsToAdd)

                    commentsToAdd = self.linearizeComments(commentsToAdd)
                    self._currentlyDisplayed.insert(contentsOf: commentsToAdd, at: selectedIndex)
                    
                    var indexPaths: [IndexPath] = []
                    for i in 0..<commentsToAdd.count {
                        indexPaths.append(IndexPath(row: selectedIndex+i, section: indexPath.section))
                    }
                    self.tableView.insertRows(at: indexPaths, with: .bottom)
                }
            } catch {
            }
        })
        task.resume()
    }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _currentlyDisplayed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CommentsTableViewCell", owner: self, options: nil)?.first as! CommentsTableViewCell
        cell.setCell(comment: _currentlyDisplayed[indexPath.row], max_depth: self.max_depth)
        cell.delegate = self
        return cell
    }
    
    open func isCellExpanded(indexPath: IndexPath) -> Bool {
        let com: Comment = _currentlyDisplayed[indexPath.row]
        return _currentlyDisplayed.count > indexPath.row+1 &&  // if not last cell
            _currentlyDisplayed[indexPath.row+1].depth > com.depth // if replies are displayed
    }
}

//public class Comment {
//    let id: Int!
//    var comment: String!
//    var comments: [Comment] = []
//    var depth: Int!
//    var parent: Comment?
//
//    var isMaxDepth = false
//    var isMaxLength = 0
//
//    static var count = 0
//
//    static func incrId() -> Int{
//        self.count += 1
//        return self.count
//    }
//
//    init(_ comment: String, _ parent: Comment?) {
//        self.id = Comment.incrId()
//        self.comment = comment
//        self.parent = parent
//
//        if let parent = self.parent {
//            self.depth = parent.depth + 1
//            parent.comments.append(self)
//            if parent.comments.count == MAX_LENGTH {
//                Comment(parent: parent, maxLength: 1 + Int(arc4random_uniform(2)))
//            }
//        } else {
//            self.depth = 0
//        }
//
//        if self.depth % MAX_DEPTH == 0 && self.depth != 0 {
//            Comment(comment: self)
//        }
//    }
//
//    init(parent: Comment!, maxLength: Int) {
//        self.id = Comment.incrId()
//        self.comment = ""
//        self.parent = parent
//        self.depth = parent.depth + 1
//        self.isMaxLength = maxLength
//        parent.comments.append(self)
//    }
//
//    init(comment: Comment) {
//        self.id = Comment.incrId()
//        self.comment = ""
//        self.parent = comment
//        self.depth = comment.depth + 1
//        self.isMaxDepth = true
//        comment.comments.append(self)
//    }
//}
