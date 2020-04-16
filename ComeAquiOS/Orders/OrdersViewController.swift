//
//  OrdersViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class OrdersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var foodPosts: [FoodPostObject] = []
    var favouritePosts: [FoodPostObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
    }
    
    var page = 1
    func getFoodPosts(){
        let username = "a"
        let password = "a"
        let url = URL(string: SERVER + "/food_query/page=\(page)/")! // whatever is your url
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString() // whatever is your token

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        // executing the call
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            // your stuff here
            guard let data = data else {
                return
            }
            do {
                self.foodPosts.append(contentsOf: try JSONDecoder().decode([FoodPostObject].self, from: data))
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                    self.fetchingMore = false
                    self.page += 1
                }
            } catch let jsonErr{
                print("json could'nt be parsed \(jsonErr)")
            }
        })
        task.resume()
    }
    
    var fetchingMore = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
          if !fetchingMore {
            beginBatchFetched()
          }
        }
    }
    
    func beginBatchFetched() {
        fetchingMore = true
        getFoodPosts()
    }
}

extension OrdersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return foodPosts.count
        } else if section == 1 && fetchingMore {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = foodPosts[indexPath.row]
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
            cell.plateNameLabel.text = object.plate_name
            cell.descriptionLabel.text = object.description
            cell.timeLabel.text = Date.hhmmHappenedNowTodayYesterdayWeekDay(start: object.start_time!, end: object.end_time!)
            cell.priceLabel.text = "$" + String(format:"%.2f", Double(object.price!) / 100)
            cell.setFoodPostType(type: object.food_type ?? "0000000")
            
            if object.images!.count > 0{
                guard let imageString = object.images![0].food_photo else {
                    return cell
                }
                cell.putImage(url: imageString)
            } else {
                cell.hideImage()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
}
