//
//  FoodReviewLookViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 30/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class FoodReviewLookViewController: UIViewController {

    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var image1: URLImageView!
    @IBOutlet weak var image1Width: NSLayoutConstraint!
    @IBOutlet weak var image2: URLImageView!
    @IBOutlet weak var image3: URLImageView!
    @IBOutlet weak var posterImage: URLImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var shortHeaderView: UIView!
    
    var foodPostId: Int?
    var foodPost: FoodPostObject?
    var reviews: [ReviewObject] = []
    
    var reply: ReviewReplyObject?
    var review: ReviewObject?
    var currentCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: headerView.frame.height))
        tableView.sectionHeaderHeight = headerView.frame.height
        
    }
    override func viewDidAppear(_ animated: Bool) {
        getFoodReviews()
    }
        
    func setViewDetails(){
        guard let foodPost = self.foodPost else {return}
        
        userName.text = foodPost.owner?.full_name!
        userUsername.text = foodPost.owner?.username!
        posterImage.loadImageUsingUrlString(urlString: foodPost.owner!.profile_photo!)
        posterImage.circle()
        
        let imageArray = [image1, image2, image3]
        imageScrollView.visibility = .visible
        imageScrollView.isHidden = false
        if foodPost.images!.count == 0 {
            imageScrollView.visibility = .gone
        } else if foodPost.images!.count == 1 {
            self.image1.loadImageUsingUrlString(urlString: foodPost.images![0].food_photo!)
            image1Width.constant = imageScrollView.frame.width
            image1.isHidden = false
        } else {
            for (i, image) in foodPost.images!.enumerated(){
                imageArray[i]!.visibility = .visible
                imageArray[i]!.loadImageUsingUrlString(urlString: image.food_photo!)
            }
        }
        var i = foodPost.images!.count
        while i < imageArray.count {
            imageArray[i]!.visibility = .gone
            i += 1
        }
    }
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
        guard let foodPost = self.foodPost else {return}
        var options: [String] = []
        if (foodPost.owner!.id! == USER.id){
            options.append(" Delete ")
        } else {
            options.append(" Report ");
        }
        performSegue(withIdentifier: "OptionsSegue", sender: options)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            print(scrollView.contentOffset.y, headerView.frame.height)
            if scrollView.contentOffset.y < headerView.frame.height - shortHeaderView.frame.height {
                headerTopConstraint.constant = -scrollView.contentOffset.y
                headerView.dropShadow()
            } else {
                headerTopConstraint.constant = -(headerView.frame.height - shortHeaderView.frame.height)
                headerView.dropShadow(radius: 5, opacity: 5)

            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OptionsSegue" {
            let optionsVC = segue.destination as? OptionsPopUpViewController
            optionsVC?.options = (sender as! [String])
            optionsVC?.delegate = self
        } else if segue.identifier == "WriteReplySegue" {
            let optionsVC = segue.destination as? WriteReplyTableViewCell
            optionsVC?.review = self.review
            optionsVC?.delegate = self
        } else if segue.identifier == "EditPostSegue" {
            let editPostVC = segue.destination as? EditPostViewController
            editPostVC?.foodPostId = self.foodPostId
        }
    }
}
extension FoodReviewLookViewController: ReviewCellProtocol, OptionsPopUpProtocol, WriteReplyProtocol {
    func replyAdded(reply: ReviewReplyObject) {
        for (i, child) in self.reviews.enumerated(){
            if child.id == reply.review!.id {
                child.replies![0] = reply
                break
            }
        }
        let ip = self.tableView.indexPath(for: self.currentCell!)
        guard let indexPath = ip else { return }
        self.tableView.reloadRows(at: [indexPath], with: .bottom)
    }
    
    func optionPressed(_ title: String) {
        switch title {
        case "Reply":
            performSegue(withIdentifier: "WriteReplySegue", sender: nil)
            break
        case "Delete":
            if let review = self.review {
                deleteReview(review.id!)
            }
            if let reply = self.reply {
                deleteReply(reply.id!)
            }
        case "Report":
            break
        case " Edit ":
            performSegue(withIdentifier: "EditPostSegue", sender: nil)
        case " Delete ":
            deletePost()
        case " Report ":
            break
            // reportPost()
        default:
            break
        }
    }
    
    func reviewOptionsPressed(review: ReviewObject, cell: UITableViewCell) {
        var options: [String] = []
        if (self.foodPost!.owner!.id == USER.id){
            if let replies = review.replies {
                if replies.count == 0 || replies[0].reply!.isEmpty{
                    options.append("Reply")
                }
            } else {
                options.append("Reply")
            }
            if (USER.id != review.owner!.id) {
                options.append("Report")
            }
        }
        
        if (USER.id == review.owner!.id){
            options.append("Delete")
        } else {
            options.append("Report")
        }
        self.review = review
        self.reply = nil
        self.currentCell = cell
        performSegue(withIdentifier: "OptionsSegue", sender: options)
    }
    
    func replyOptionsPressed(reply: ReviewReplyObject, cell: UITableViewCell) {
        var options: [String] = []
        if (USER.id == reply.owner!.id){
            options.append("Delete")
        } else {
            options.append("Report")
        }
        self.review = nil
        self.reply = reply
        self.currentCell = cell
        performSegue(withIdentifier: "OptionsSegue", sender: options)
    }
}
extension FoodReviewLookViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell") as! ReviewTableViewCell
        let review = self.reviews[indexPath.row]
        cell.setCell(review: review)
        cell.delegate = self
        cell.review = review
        return cell
    }
    
    func deleteReviewFromTable(review: ReviewObject) {
        // Do whatever you want from your button here.
        for (i, child) in self.reviews.enumerated(){
            if child.id == review.id {
                self.reviews.remove(at: i)
                break
            }
        }
        let ip = self.tableView.indexPath(for: self.currentCell!)
        guard let indexPath = ip else { return }
        self.tableView.deleteRows(at: [indexPath], with: .bottom)
    }
}

extension FoodReviewLookViewController {
    func getFoodReviews(){
        guard let foodPostId = self.foodPostId else {return}
        Server.get( "/food_reviews/\(foodPostId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            guard let data = data else {return}
            do {
                self.foodPost = try JSONDecoder().decode(FoodPostObject.self, from: data)
                DispatchQueue.main.async {
                    self.reviews = self.foodPost!.reviews!
                    self.tableView.reloadData()
                    self.setViewDetails()
                }
            } catch {}
        })
    }
    func deletePost(){
        guard let foodPostId = self.foodPostId else { return }
        Server.delete("/foods/\(foodPostId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            guard let _ = data else {return}
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    func deleteReview(_ reviewId: Int){
        Server.delete( "/delete_review/\(reviewId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            guard let _ = data else {return}
            DispatchQueue.main.async {
                self.deleteReviewFromTable(review: self.review!)
            }
        })
    }
    func deleteReply(_ replyId: Int){
        Server.delete( "/delete_reply/\(replyId)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            guard let _ = data else {return}
            DispatchQueue.main.async {
                self.getFoodReviews()
            }
        })
    }
}
