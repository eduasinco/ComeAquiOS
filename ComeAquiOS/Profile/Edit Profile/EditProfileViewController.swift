//
//  EditProfileViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 10/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
private class ResponseObject: Decodable {
    var error_message: String?
    var data: [PaymentMethodObject]?
}

class EditProfileViewController: LoadViewController {

    @IBOutlet weak var profileImage: URLImageView!
    @IBOutlet weak var backgroundImage: URLImageView!
    @IBOutlet weak var bioText: UITextView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var surname: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var creditCard: UILabel!
    
    var user: User?
    var paymentMethod: PaymentMethodObject?
    var isBackgroundImageChanging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUser()
    }
    
    func setView(){
        guard let user = self.user else {return}
        backgroundImage.loadImageUsingUrlString(urlString: user.background_photo, isFullUrl: true)
        profileImage.loadImageUsingUrlString(urlString: user.profile_photo, isFullUrl: true)
        name.text = user.first_name
        surname.text = user.last_name
        bioText.text = user.bio
        
        guard let paymentMethod = self.paymentMethod else {return}
        creditCard.text = paymentMethod.last4
    }
    
    @IBAction func editProfileImage(_ sender: Any) {
        isBackgroundImageChanging = false
        performSegue(withIdentifier: "GalleryCameraSegue", sender: nil)
    }
    @IBAction func editBackgroundImage(_ sender: Any) {
        isBackgroundImageChanging = true
        performSegue(withIdentifier: "GalleryCameraSegue", sender: nil)
    }
    @IBAction func addBio(_ sender: Any) {
    }
    @IBAction func editAccountDetails(_ sender: Any) {
    }
    @IBAction func editBankAccountDetails(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GalleryCameraSegue" {
            let gcVC = segue.destination as? GaleryCameraPopUpViewController
            gcVC?.delegate = self
        }
    }
}

extension EditProfileViewController: GaleryCameraPopUpProtocol {
    func image(_ image: UIImage) {
        if isBackgroundImageChanging {
            present(alert, animated: false, completion: nil)
            Server.uploadPictures(method: .patch, urlString: SERVER + "/edit_profile/", withName: "background_photo", pictures: image, finish: {(data: Data?) -> Void in
                DispatchQueue.main.async {
                    self.alert.dismiss(animated: false, completion: nil)
                }
                guard data != nil else {return}
            })
            backgroundImage.image = image
        } else {
            present(alert, animated: false, completion: nil)
            Server.uploadPictures(method: .patch, urlString: SERVER + "/edit_profile/", withName: "profile_photo", pictures: image, finish: {(data: Data?) -> Void in
                DispatchQueue.main.async {
                    self.alert.dismiss(animated: false, completion: nil)
                }
                guard data != nil else {return}
            })
            profileImage.image = image
        }
    }
}

extension EditProfileViewController {
    func getUser(){
        present(alert, animated: false, completion: nil)
        Server.get("/profile_detail/\(USER.id!)/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            guard let data = data else {
                return
            }
            do {
                self.user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.getChosenCard()
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
                DispatchQueue.main.async {
                    self.alert.dismiss(animated: false, completion: nil)
                }
            }
        })
    }
    func getChosenCard(){
        Server.get("/my_chosen_card/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                self.alert.dismiss(animated: false, completion: nil)
            }
            guard let data = data else {
                return
            }
            do {
                let responseO = try JSONDecoder().decode(ResponseObject.self, from: data)
                if responseO.error_message == nil {
                    if let data = responseO.data, data.count > 0 {
                        self.paymentMethod = data[0]
                    }
                    DispatchQueue.main.async {
                        self.setView()
                    }
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        })
    }
}

