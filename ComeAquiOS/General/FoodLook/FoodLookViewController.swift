//
//  FoodLookViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
import GoogleMaps

class FoodLookViewController: KUIViewController {
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var image1: URLImageView!
    @IBOutlet weak var image2: URLImageView!
    @IBOutlet weak var image3: URLImageView!
    @IBOutlet weak var image1Width: NSLayoutConstraint!
    @IBOutlet weak var detailStackView: UIStackView!
    @IBOutlet weak var detailStackViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var shortHeaderView: UIView!
    @IBOutlet weak var userImage: URLImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUserName: UILabel!
    
    @IBOutlet weak var plateName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var mealDescription: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var viewToShowMap: UIView!
    @IBOutlet weak var dinnersStackView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var dinnersText: UILabel!
    @IBOutlet weak var dinnerScrollView: UIScrollView!
    @IBOutlet weak var addPaymentMethodButton: UIButton!
    @IBOutlet weak var attendMealButton: UIButton!
    @IBOutlet weak var creditCardInfoView: UIView!
    @IBOutlet weak var creditCardImage: UIImageView!
    @IBOutlet weak var creditCardNumber: UILabel!
    @IBOutlet weak var commentTextViewStack: UIStackView!
    @IBOutlet weak var commentTextField: UITextView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var bcfkb: NSLayoutConstraint!
    
    var typesVC: TypesViewController?
    
    var googleMap: GMSMapView!
    var foodPostId: Int!
    var foodPost: FoodPostObject?
    var paymentMethod: PaymentMethodObject?
    var commentsVC: CommentsViewController?
    private var respondObject: ResponseFoodPostObject?
    
    var headerOriginalHeight: CGFloat!
    var imageScrollViewOriginalHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentScrollView.delegate = self
        imageScrollView.delegate = self
        textView.delegate = self
        textView.isScrollEnabled = false
        self.bottomConstraintForKeyboard = bcfkb
        sendButton.visibility = .gone
        attendMealButton.visibility = .gone
        commentTextField.isUserInteractionEnabled = false
        dinnersStackView.isUserInteractionEnabled = true
        dinnersStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction(sender:))))
        commentTextViewStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.tapComment(sender:))))
        viewToShowMap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapMap(_:))))
        sendCommentButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (sendComment)))
    }
        
    @objc func sendComment(){
        self.view.endEditing(true)
        postComment()
        self.textView.text = ""
        self.sendButton.visibility = .gone
    }
    @objc func tapMap(_ gestureRecognizer: UITapGestureRecognizer) {
        openMap(lat: foodPost!.lat!, lng: foodPost!.lng!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFoodPost()
    }

    @objc func checkAction(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "DinnerSegue", sender: nil)
    }
    
    @objc func tapComment(sender : UITapGestureRecognizer) {
        self.holderView.showToast(message: "You can't comment until meal is confirmed")
    }
    
    @objc func goToProfile(){
        performSegue(withIdentifier: "ProfileSegue", sender: nil)
    }
    
    @IBAction func addPaymentMethod(_ sender: Any) {
        performSegue(withIdentifier: "AddPaymentSegue", sender: nil)
    }
    @IBAction func changePaymentMethod(_ sender: Any) {
        performSegue(withIdentifier: "AddPaymentSegue", sender: nil)
    }
    
    func setViewDetails(){
        guard let foodPost = self.foodPost else {return}
        
        userName.text = foodPost.owner?.full_name!
        userUserName.text = foodPost.owner?.username!
        userImage.loadImageUsingUrlString(urlString: foodPost.owner!.profile_photo_)
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToProfile)))
        typesVC?.setTypes(typeString: foodPost.food_type ?? "0000000")
        
        let imageArray = [image1, image2, image3]
        imageScrollView.visibility = .visible
        imageScrollView.isHidden = false
        if foodPost.images!.count == 0 {
            imageScrollView.visibility = .gone
        } else if foodPost.images!.count == 1 {
            self.image1.loadImageUsingUrlString(urlString: foodPost.images![0].food_photo_)
            image1Width.constant = imageScrollView.frame.width
            image1.isHidden = false
        } else {
            for (i, image) in foodPost.images!.enumerated(){
                imageArray[i]!.visibility = .visible
                imageArray[i]!.loadImageUsingUrlString(urlString: image.food_photo_)
            }
        }
        var i = foodPost.images!.count
        while i < imageArray.count {
            imageArray[i]!.visibility = .gone
            i += 1
        }
        setOnImageClicked()
        
        headerView.layoutIfNeeded()
        detailStackViewTopConstraint.constant = headerView.frame.height
        headerOriginalHeight = headerView.frame.height
        imageScrollViewOriginalHeight = imageScrollViewHeight.constant
        
        plateName.text = foodPost.plate_name
        date.text = foodPost.time_to_show!
        time.text = Date.timeRange(start: foodPost.start_time!, end: foodPost.end_time!)
        price.text = "$" + String(format:"%.2f", Double(foodPost.price!) / 100)
        mealDescription.text = foodPost.description
        addressLabel.text = foodPost.formatted_address
        
        GMSServices.provideAPIKey(GOOGLE_MAPS_KEY)
        let camera = GMSCameraPosition.camera(withLatitude: foodPost.lat!, longitude: foodPost.lng!, zoom: 15.0)
        googleMap = GMSMapView.map(withFrame: view.bounds, camera: camera)
        googleMap.isMyLocationEnabled = true
        googleMap.isMyLocationEnabled = true
        googleMap.delegate = self
        googleMap.isUserInteractionEnabled = false
        viewToShowMap.addSubview(googleMap)
        viewToShowMap.clipsToBounds = true
        setDinners()
        
        if USER.id == foodPost.owner!.id {
            attendMealButton.visibility = .gone
        }
        addPaymentMethodButton.visibility = .gone
        attendMealButton.visibility = .gone
        creditCardInfoView.visibility = .gone
        commentsView.visibility = .gone
        if USER.id == foodPost.owner!.id {
            commentsView.visibility = .visible
            setStatus(text: "Confirmed", color: UIColor(named: "Success")!)
            commentsView.visibility = .visible
            commentTextField.isUserInteractionEnabled = true
        } else {
            switch self.respondObject?.user_status_in_this_post {
            case "CONFIRMED":
                setStatus(text: "Confirmed", color: UIColor(named: "Success")!)
                commentsView.visibility = .visible
                commentTextField.isUserInteractionEnabled = true
            case "PENDING":
                setStatus(text: "Pending", color: UIColor(named: "Primary")!)
            case "CANCELED":
                setStatus(text: "Canceled", color: UIColor(named: "Canceledd")!)
            case "REJECTED":
                setStatus(text: "Rejected", color: UIColor(named: "Canceledd")!)
            case "FINISHED":
                setStatus(text: "Finished", color: UIColor(named: "Primary")!)
                commentsView.visibility = .visible
                commentTextField.isUserInteractionEnabled = true
            default:
                switch foodPost.status {
                case "OPEN":
                    attendMealButton.addTarget(self, action: #selector(attendMeal(sender:)), for: .touchUpInside)
                case "IN_COURSE":
                    setStatus(text: "Meal in course", color: UIColor(named: "Primary")!)
                case "FINISHED":
                    setStatus(text: "Meal finished", color: UIColor(named: "Primary")!)
                default:
                    break
                }
            }
            if let paymentMethod = self.paymentMethod {
                addPaymentMethodButton.visibility = .gone
                attendMealButton.visibility = .visible
                creditCardInfoView.visibility = .visible
                creditCardNumber.text = paymentMethod.last4
            } else {
                addPaymentMethodButton.visibility = .visible
            }
        }
    }
    
    func setOnImageClicked(){
        for (i, imageView) in [image1, image2, image3].enumerated(){
            imageView?.tag = i
            imageView?.isUserInteractionEnabled = true
            imageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        }
    }
    @objc private func imageTapped(_ recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "ImagePagerSegue", sender: recognizer.view?.tag)
    }
    
    func createDinnerView(order: OrderObject) -> UIView {
        let dv = UIView()
        let imageView = URLImageView()
        dv.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        dv.addSubview(imageView)
        dv.widthAnchor.constraint(equalToConstant: dinnersStackView.frame.height).isActive = true

        imageView.leadingAnchor.constraint(equalTo: dv.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: dv.topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: dv.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: dv.bottomAnchor).isActive = true
        
        if order.additional_guests! >= 0 {
            let label = UILabel()
            dv.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.white
            label.backgroundColor = UIColor(named: "Secondary")
            label.topAnchor.constraint(equalTo: dv.topAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: dv.trailingAnchor).isActive = true
            if order.additional_guests ?? 0 > 0 {
                label.text = " \(order.additional_guests!)+ "
            } else {
                label.text = ""
            }
            dinnerLabels.append(label)
        }
        imageView.loadImageUsingUrlString(urlString: order.owner!.profile_photo_)
        imageView.contentMode = .scaleAspectFill
        dinnerImages.append(imageView)
        return dv
    }
    
    func setStatus(text: String, color: UIColor){
        attendMealButton.setTitle(text, for: .normal)
        attendMealButton.setTitleColor(UIColor.white, for: .normal)
        attendMealButton.backgroundColor = color
    }
    
    @objc func attendMeal(sender: UIButton!) {
        performSegue(withIdentifier: "AttendSegue", sender: nil)
        
    }
    @IBAction func optionsPressed(_ sender: Any) {
        performSegue(withIdentifier: "OptionsSegue", sender: nil)
    }
    
    var dinnerImages: [URLImageView] = []
    var dinnerLabels: [UILabel] = []
    func setDinners(){
        guard let confirmed_orders = self.foodPost?.confirmed_orders else { return }
        if confirmed_orders.count > 0 {
            dinnersText.text = "\(confirmed_orders.count)/\(self.foodPost!.max_dinners!) dinners"
            dinnerImages = []
            for view in self.dinnersStackView.subviews {
                view.removeFromSuperview()
            }
            for order in confirmed_orders {
                dinnersStackView.addArrangedSubview(createDinnerView(order: order))
            }
        } else {
            dinnersText.text = "No dinners yet"
            dinnerScrollView.visibility = .gone
        }
    }
    
    override func viewDidLayoutSubviews() {
        for image in dinnerImages {
            image.isRounded = true
        }
        for label in dinnerLabels {
            label.isRounded = true
        }
    }
    
    func openMap(lat: Double, lng: Double) {
        let appleURL = "http://maps.apple.com/?daddr=\(lat),\(lng)"
        let googleURL = "comgooglemaps://?daddr=\(lat),\(lng)&directionsmode=driving"
        let wazeURL = "waze://?ll=\(lat),\(lng)&navigate=false"

        let googleItem = ("Google Map", URL(string:googleURL)!)
        let wazeItem = ("Waze", URL(string:wazeURL)!)
        var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]

        if UIApplication.shared.canOpenURL(googleItem.1) {
            installedNavigationApps.append(googleItem)
        }

        if UIApplication.shared.canOpenURL(wazeItem.1) {
            installedNavigationApps.append(wazeItem)
        }

        let alert = UIAlertController(title: "Selection", message: "Select Navigation App", preferredStyle: .actionSheet)
        for app in installedNavigationApps {
            let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                UIApplication.shared.open(app.1, options: [:], completionHandler: nil)
            })
            alert.addAction(button)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DinnerSegue" {
            let dinnerVC = segue.destination as? DinnersViewController
            dinnerVC?.foodPostId = self.foodPostId
        } else if segue.identifier == "OptionsSegue" {
            let optionsVC = segue.destination as? OptionsPopUpViewController
            guard let foodPost = self.foodPost else {return}
            var options: [String] = []
            if (foodPost.owner!.id! == USER.id){
                options.append("Edit");
                if (foodPost.confirmed_orders?.count == 0 || (foodPost.confirmed_orders!.count > 0 && foodPost.confirmed_orders?[0].order_status == "FINISHED")){
                    options.append("Delete");
                }
            } else {
                options.append("Report");
            }
            optionsVC?.options = options
            optionsVC?.delegate = self
        } else if segue.identifier == "EditPostSegue" {
            let editPostVC = segue.destination as? EditPostViewController
            editPostVC?.foodPostId = self.foodPostId
        } else if segue.identifier == "AttendSegue" {
            let attendVC = segue.destination as? AttendPopUpViewController
            attendVC?.dinners_left = self.foodPost?.dinners_left
            attendVC?.price = self.foodPost?.price
            attendVC?.delegate = self
        } else if segue.identifier == "OrderLookSegue" {
            let orderVC = segue.destination as? OrderLookViewController
            orderVC?.orderId = (sender as! OrderObject).id
        } else if segue.identifier == "AddPaymentSegue" {
            _ = segue.destination as? AddPaymentMethodViewController
        } else if segue.identifier == "CommentsSegue" {
            commentsVC = segue.destination as? CommentsViewController
            commentsVC?.foodPostId = foodPostId
        } else if segue.identifier == "TypeSegue" {
            typesVC = segue.destination as? TypesViewController
        } else if segue.identifier == "ImagePagerSegue" {
            let vc = segue.destination as? ImagePagerViewController
            vc?.data = foodPost?.images ?? []
            vc?.indexPath = IndexPath(row: sender as? Int ?? 1, section: 0)
        } else if segue.identifier == "ProfileSegue" {
            let vc = segue.destination as? ProfileViewController
            vc?.userId = foodPost?.owner?.id
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FoodLookViewController: OptionsPopUpProtocol, AttendMealProtocol {
    func confirmAttend(additionalGuests: Int) {
        createOrder(additionalGuests: additionalGuests)
    }
    
    func optionPressed(_ title: String) {
        switch title {
        case "Edit":
            performSegue(withIdentifier: "EditPostSegue", sender: nil)
        case "Delete":
            deletePost()
        case "Report":
            break
            // reportPost()
        default:
            break
        }
    }
}

extension FoodLookViewController: GMSMapViewDelegate {
    @objc(mapView:didTapMarker:) func mapView(_: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }
}

extension FoodLookViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == parentScrollView{
            if scrollView.contentOffset.y > headerOriginalHeight - shortHeaderView.frame.height {
                headerTopConstraint.constant = -headerView.frame.height + shortHeaderView.frame.height + scrollView.contentOffset.y
                headerView.dropShadow(radius: 5, opacity: 5)
            } else {
                headerTopConstraint.constant = 0
                headerView.dropShadow()
            }
            
            if scrollView.contentOffset.y < 0 {
                imageScrollViewHeight.constant = imageScrollViewOriginalHeight - scrollView.contentOffset.y
                headerTopConstraint.constant = scrollView.contentOffset.y
            } else {
                imageScrollViewHeight.constant = imageScrollViewOriginalHeight
            }
        }
    }
}

extension FoodLookViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if textView.text.count > 0 {
            sendButton.visibility = .visible
        } else {
            sendButton.visibility = .gone
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}

extension FoodLookViewController {
    private struct ResponseFoodPostObject: Decodable{
        var user_status_in_this_post: String?
        var food_post: FoodPostObject?
    }
    func getFoodPost(){
        presentLoader()
        guard let foodPostId = self.foodPostId else { return }
        Server.get("/food_with_user_status/\(foodPostId)/"){ data, response, error in
            if let _ = error {
                self.onReload = self.getFoodPost
            }
            self.closeLoader()
            guard let data = data else {return}
            do {
                self.respondObject = try JSONDecoder().decode(ResponseFoodPostObject.self, from: data)
                self.foodPost = self.respondObject!.food_post
                DispatchQueue.main.async {
                    self.getChosenCard()
                }
            } catch {}
        }
    }
    private struct ResponseObject: Decodable{
        var error_message: String?
        var data: [PaymentMethodObject]?
    }
    func getChosenCard(){
        presentLoader()
        Server.get("/my_chosen_card/"){ data, response, error in
            self.closeLoader()
            guard let data = data else { return }
            do {
                let responseO = try JSONDecoder().decode(ResponseObject.self, from: data)
                if responseO.error_message == nil {
                    if let data = responseO.data, data.count > 0 {
                        self.paymentMethod = data[0]
                    }
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
            DispatchQueue.main.async {
                self.setViewDetails()
            }
        }
    }
    
    func deletePost(){
        guard let foodPostId = self.foodPostId else { return }
        Server.delete("/foods/\(foodPostId)/"){ data, response, error in
            guard let _ = data else {return}
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func postComment(){
        Server.post("/food_post_comment/\(self.foodPost!.id!)/",
            json:
            [
                "post_id": foodPost?.id ?? nil,
                "comment_id": nil,
                "message": textView.text!
            ]) { data, response, error in
            if let _ = error {
                self.view.showToast(message: "No internet connection")
            }
                guard let data = data else {return}
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                    DispatchQueue.main.async {
                        let newComment = Comment(json: json, parent: nil)
                        DispatchQueue.main.async {
                            self.commentsVC?.commentAddedToPost(newComment: newComment)
                        }
                    }
                } catch _ {
                    self.view.showToast(message: "Some error ocurred")
                }
        }
    }
    private struct ResponseOrderObject: Decodable{
        var order: OrderObject?
        var error_message: String?
    }
    func createOrder(additionalGuests: Int){
        Server.post("/create_order_and_notification/",
            json:
            [
                "food_post_id": self.foodPost!.id!,
                "additional_guests": additionalGuests,
            ]) { data, response, error in
            if let _ = error {
                self.view.showToast(message: "No internet connection")
            }
                guard let data = data else {return}
                
                do {
                    let res = try JSONDecoder().decode(ResponseOrderObject.self, from: data)
                    if let error = res.error_message{
                        self.parentScrollView.showToast(message: error)
                    } else {
                        let order = res.order
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "OrderLookSegue", sender: order)
                        }
                    }
                } catch {}
        }
    }
}
