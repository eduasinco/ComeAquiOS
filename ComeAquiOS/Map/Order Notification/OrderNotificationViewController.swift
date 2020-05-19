//
//  OrderNotificationViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 19/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class OrderNotificationViewController: CardBehaviourViewController {

    @IBOutlet weak var wholeView: UIView!
    
    @IBOutlet weak var hostingView: UIView!
    @IBOutlet weak var timeHosting: UILabel!
    
    @IBOutlet weak var guestingView: UIView!
    @IBOutlet weak var mealWithUser: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    @IBOutlet weak var plateName: UILabel!
    @IBOutlet weak var timeGuesting: UILabel!
    
    var order: OrderObject?
    var foodPost: FoodPostObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hostingView.visibility = .gone
        self.guestingView.visibility = .gone
        addTopCardBehaviour(view: view, onHide: {() -> Void in })
    }
    func setOrder(){
        guard let order = self.order else {return}
        self.hostingView.visibility = .visible
        self.timeHosting.text = order.post?.start_time
    }
    func setFoodPost(){
        guard let post = self.foodPost else {return}
        self.guestingView.visibility = .visible
        mealWithUser.text = post.owner?.full_name
        userUsername.text = post.owner?.username
        plateName.text = post.plate_name
        timeGuesting.text = post.start_time
    }
}

extension OrderNotificationViewController {
    func getConfirmOrders() {
        Server.get("/my_next_confirmed_order/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            guard let data = data else {
                return
            }
            do {
                let orders = try JSONDecoder().decode([OrderObject].self, from: data)
                if orders.count > 0 {
                    self.order = orders[0]
                    DispatchQueue.main.async {
                        self.setOrder()
                    }
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
    }
    func getConfirmPosts() {
        Server.get("/my_next_confirmed_post/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            guard let data = data else {
                return
            }
            do {
                let posts = try JSONDecoder().decode([FoodPostObject].self, from: data)
                if posts.count > 0 {
                    self.foodPost = posts[0]
                    DispatchQueue.main.async {
                        self.setFoodPost()
                    }
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
    }
}
