//
//  EditPostViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 28/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class EditPostViewController: KUIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var plateNameText: ValidatedTextField!
    @IBOutlet weak var descriptionText: ValidatedTextView!
    @IBOutlet weak var wordCountText: UILabel!
    @IBOutlet weak var holderBottomConstraint: NSLayoutConstraint!
    
    var typesVC: TypesViewController?
    var importImageVC: ImportImagesViewController?
    
    var types: String?
    var descriptionString: String?
    
    var foodPost: FoodPostObject?
    var foodPostId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomConstraintForKeyboard = holderBottomConstraint
        descriptionText.textFieldBorderStyle()
        descriptionText.delegate = self
        

        present(alert, animated: false, completion: nil)
        
        guard let foodPostId = self.foodPostId else { return }
        self.importImageVC?.foodPostId = foodPostId
        getFoodPost()
    }
    func setFoodPost() {
        if (self.foodPost?.plate_name) != nil {
            plateNameText.text = self.foodPost?.plate_name
        }
        if let description = self.foodPost?.description {
            self.descriptionText.text = description
        }
        if let images = self.foodPost?.images {
            importImageVC?.setImages(images: images)
        }
        self.setTypeVC()
    }
    
    func validateData() -> Bool{
        var valid = true
        if plateNameText.text == nil || plateNameText.text!.isEmpty {
            plateNameText.validationText = "Meal should not be empty"
            valid = false
        }
        if descriptionText.text == nil || descriptionText!.text!.isEmpty  {
            descriptionText.validationText = "Meal description should not be empty"
            valid = false
        }
        return valid
    }
    
    @IBAction func editPost(_ sender: Any) {
        if validateData() {
            pathFoodPost(visible: true)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        wordCountText.text = "\(numberOfChars)/202"
        return numberOfChars < 202    // 10 Limit Value
    }
    func setTypeVC() {
        let storyboard = UIStoryboard(name: "TypesStoryboard", bundle: nil)
        typesVC = storyboard.instantiateViewController(identifier: "TypesView") as? TypesViewController
        if let typesVC = self.typesVC {
            typesVC.initialTypesString = self.foodPost?.food_type ?? "0000000"
            typesVC.delegate = self
            addChild(typesVC)
            stackView.insertArrangedSubview(typesVC.view, at: 1)
            typesVC.didMove(toParent: self)
            let h = typesVC.view.heightAnchor.constraint(equalToConstant: 20)
            h.priority = UILayoutPriority(rawValue: 1000)
            h.isActive = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageImporterSegue" {
            importImageVC = segue.destination as? ImportImagesViewController
            importImageVC?.delegate = self
            importImageVC?.foodPostId = self.foodPost?.id
        }
    }
}

extension EditPostViewController {
    func getFoodPost(){
        Server.get("/foods/\(foodPostId!)/", finish: {
            (data: Data?, response: URLResponse?) -> Void in
            DispatchQueue.main.async {
                self.alert.dismiss(animated: false, completion: nil)
            }
            guard let data = data else {
                return
            }
            do {
                self.foodPost = try JSONDecoder().decode(FoodPostObject.self, from: data)
                DispatchQueue.main.async {
                    self.setFoodPost()
                }
            } catch let jsonErr {
                print("json could'nt be parsed \(jsonErr)")
            }
        })
    }
    func pathFoodPost(visible: Bool){
        Server.patch("/edit_food/\(self.foodPost!.id!)/",
            json:
            [
                "plate_name":  plateNameText.text,
                "food_type":  types,
                "description":  descriptionText.text,
            ],
            finish: {(data: Data?, response: URLResponse?) -> Void in
                DispatchQueue.main.async {
                    self.alert.dismiss(animated: false, completion: nil)
                }
                guard let data = data else {
                    return
                }
                do {
                    self.foodPost = try JSONDecoder().decode(FoodPostObject.self, from: data)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                } catch let jsonErr {
                    print("json could'nt be parsed \(jsonErr)")
                }
        }, error: {(data: Data?) -> Void in })
    }
}

extension EditPostViewController: TypesProtocol, ImportImagesProtocol {
    func images(images: [UIImage]) {}
    func typeChanged(types: String) {
        self.types = types
    }
}


