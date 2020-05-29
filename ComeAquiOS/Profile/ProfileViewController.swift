//
//  ProfileViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ProfileViewController: LoadViewController {
    
    @IBOutlet weak var headerView: PassthroughView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerHeighConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var externalScrollView: UIScrollView!
    @IBOutlet weak var scrollView1: UIScrollView!
    @IBOutlet weak var scrollView1Width: NSLayoutConstraint!
    @IBOutlet weak var container1TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView2: UIScrollView!
    @IBOutlet weak var container2TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView3: UIScrollView!
    @IBOutlet weak var container3TopConstraint: NSLayoutConstraint!
    var headerFrame: CGRect!
    
    @IBOutlet weak var backgoundImage: ImageToOpen!
    @IBOutlet weak var changeBackgroundImageButton: UIButton!
    @IBOutlet weak var profileImage: ImageToOpen!
    @IBOutlet weak var changeProfileImageButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    var rateVC: RateStarViewController?
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var editProfileButtonContainer: UIView!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var messageButtonContainer: UIView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    var tab1VC: Tab1ViewController?
    var tab2VC: Tab2ViewController?
    var tab3VC: Tab3ViewController?

    
    var userId: Int?
    var user: User?
    var isBackgroundImageChanging = true
    var options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        externalScrollView.delegate = self
        scrollView1.delegate = self
        scrollView2.delegate = self
        scrollView3.delegate = self
        scrollView1Width.constant = self.view.frame.width
        container1TopConstraint.constant = headerView.frame.height
        container2TopConstraint.constant = headerView.frame.height
        container3TopConstraint.constant = headerView.frame.height
        segmentView.isExclusiveTouch = true
        headerFrame = headerView.frame
    }
    override func viewWillAppear(_ animated: Bool) {
        if let profileId = self.userId {
            getUser(profileId)
        } else {
            getUser(USER.id)
        }
    }
    func setView(){
        guard let user = self.user else {return}
        if user.id == USER.id{
            messageButtonContainer.visibility = .gone
            changeProfileImageButton.visibility = .visible
            changeBackgroundImageButton.visibility = .visible
            options = ["Log out"]
        } else {
            options = ["Message user", "Report"]
            editProfileButtonContainer.visibility = .gone
            changeProfileImageButton.visibility = .gone
            changeBackgroundImageButton.visibility = .gone
        }
        backgoundImage.loadImageUsingUrlString(urlString: user.background_photo, isFullUrl: true)
        profileImage.loadImageUsingUrlString(urlString: user.profile_photo, isFullUrl: true)
        userName.text = user.full_name
        self.title = user.username
        self.toolbarItems?[3].title = nil
        rateVC?.setRate(rating: user.rating!, rating_n: user.rating_n!)
        
        if user.bio != nil && user.bio!.isEmpty {
            bioTextView.visibility = .gone
        } else {
            bioTextView.text = user.bio
        }
        tab1VC?.userId = user.id
        tab2VC?.userId = user.id
        tab3VC?.userId = user.id
    }
    
    var changingIndex = false
    @IBAction func indexChanged(_ sender: Any) {
        changingIndex = true
        let x = segmentView.selectedSegmentIndex * Int(externalScrollView.frame.width)
        externalScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    @IBAction func changeBackgroundImage(_ sender: Any) {
        isBackgroundImageChanging = true
        performSegue(withIdentifier: "GalleryCameraSegue", sender: nil)
    }
    
    @IBAction func changeProfileImage(_ sender: Any) {
        isBackgroundImageChanging = false
        performSegue(withIdentifier: "GalleryCameraSegue", sender: nil)
    }
    @IBAction func editProfile(_ sender: Any) {
        performSegue(withIdentifier: "EditProfileSegue", sender: nil)
    }
    @IBAction func openConversationWithUser(_ sender: Any) {
        getConversation()
    }
    @IBAction func options(_ sender: Any) {
        performSegue(withIdentifier: "OptionsSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RateSegue"{
            rateVC = segue.destination as? RateStarViewController
        } else if segue.identifier == "GalleryCameraSegue" {
            let gcVC = segue.destination as? GaleryCameraPopUpViewController
            gcVC?.delegate = self
        } else if segue.identifier == "OptionsSegue" {
            let optionsVC = segue.destination as? OptionsPopUpViewController
            optionsVC?.options = self.options
            optionsVC?.delegate = self
        } else if segue.identifier == "EditProfileSegue" {
            _ = segue.destination as? EditProfileViewController
        } else if segue.identifier == "Tab1Segue" {
            tab1VC = segue.destination as? Tab1ViewController
        } else if segue.identifier == "Tab2Segue" {
            tab2VC = segue.destination as? Tab2ViewController
        } else if segue.identifier == "Tab3Segue" {
            tab3VC = segue.destination as? Tab3ViewController
        } else if segue.identifier == "LoginOrRegisterSegue" {
            let loginVC = segue.destination as? LoginOrRegisterViewController
        } else if segue.identifier == "ConversationSegue" {
            let vc = segue.destination as? ConversationViewController
            vc?.chatId = sender as? Int
        }
    }
}

extension ProfileViewController: GaleryCameraPopUpProtocol, OptionsPopUpProtocol, ImageLookerProtocol {
    func deleteImage(_ urlImage: String?) {
        if profileImage.urlString == urlImage{
            deleteUserImages(profile: true)
        }
        if backgoundImage.urlString == urlImage{
            deleteUserImages(profile: false)
        }
    }
    
    func optionPressed(_ title: String) {
        switch title {
        case "Log out":
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "username")
            defaults.removeObject(forKey: "password")
            self.performSegue(withIdentifier: "LoginOrRegisterSegue", sender: nil)
            break
        case "Message user":
            break
        case "Report":
            break
        default:
            break
        }
    }
    func image(_ image: UIImage) {
        if isBackgroundImageChanging {
            Server.uploadPictures(method: .patch, urlString: SERVER + "/edit_profile/", withName: "background_photo", pictures: image, finish: {(data: Data?) -> Void in
                DispatchQueue.main.async {
                    self.getUser(USER.id)
                }
            })
        } else {
            Server.uploadPictures(method: .patch, urlString: SERVER + "/edit_profile/", withName: "profile_photo", pictures: image, finish: {(data: Data?) -> Void in
                DispatchQueue.main.async {
                    self.getUser(USER.id)
                }
            })
        }
        
    }
}

extension ProfileViewController {
    func getUser(_ userId: Int){
        Server.get("/profile_detail/\(userId)/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                
            }
            guard let data = data else {
                return
            }
            do {
                self.user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.setView()
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
    }
    func getConversation(){
        guard let user = self.user else { return }
        Server.get("/get_or_create_chat/\(user.id!)/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                
            }
            guard let data = data else {
                return
            }
            do {
                let chat = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "ConversationSegue", sender: chat.id)
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
    }
    func deleteUserImages(profile: Bool){
        Server.delete("/delete_user_images/\(profile ? 1 : 0)/",
            finish: {(data: Data?, response: URLResponse?) -> Void in
                guard let data = data else {return}
                do {
                    self.user = try JSONDecoder().decode(User.self, from: data)
                    DispatchQueue.main.async {
                        self.setView()
                    }
                } catch _ {
                    self.view.showToast(message: "Some error ocurred")
                }
        })
    }
}


extension ProfileViewController: UIScrollViewDelegate, UIGestureRecognizerDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        changingIndex = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == externalScrollView {
            if !changingIndex{
                segmentView.selectedSegmentIndex = Int(round(externalScrollView.contentOffset.x / externalScrollView.frame.size.width))
            }
        } else {
            let d = headerView.frame.height - segmentView.frame.height
            if scrollView.contentOffset.y >= d {
                headerTopConstraint.constant = -d
                if scrollView == scrollView1 && scrollView2.contentOffset.y < d && scrollView3.contentOffset.y < d {
                    scrollView2.contentOffset.y = d
                    scrollView3.contentOffset.y = d
                } else if scrollView == scrollView2 && scrollView1.contentOffset.y < d && scrollView3.contentOffset.y < d {
                    scrollView1.contentOffset.y = d
                    scrollView3.contentOffset.y = d
                } else if scrollView == scrollView3 && scrollView1.contentOffset.y < d && scrollView2.contentOffset.y < d {
                    scrollView1.contentOffset.y = d
                    scrollView2.contentOffset.y = d
                }
            } else {
                scrollView1.contentOffset.y = scrollView.contentOffset.y
                scrollView2.contentOffset.y = scrollView.contentOffset.y
                scrollView3.contentOffset.y = scrollView.contentOffset.y
                
                if scrollView.contentOffset.y < 0 {
                    headerTopConstraint.constant = 0
                    headerHeighConstraint.constant = headerFrame.height - scrollView.contentOffset.y
                } else {
                    headerTopConstraint.constant = -scrollView.contentOffset.y
                }
            }
        }
        
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            if scrollView == scrollView1 {
                tab1VC!.fetchMoreData()
            } else if scrollView == scrollView2 {
                tab2VC!.fetchMoreData()
            } else if scrollView == scrollView3 {
                tab3VC!.fetchMoreData()
            }
        }
    }
}

