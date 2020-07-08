//
//  Tab3ViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 08/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class Tab3ViewController: UIViewController {
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noMediaView: UIView!
    
    var data: [FoodPostImageObject] = []
    var userId : Int? {
        didSet{
            page = 1
            data = []
            self.getUserImages()
        }
    }
    var page: Int = 1
    var alreadyFetchingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let itemSize = UIScreen.main.bounds.width/3 - 2
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        collectionView.collectionViewLayout = layout
    }
    override func viewWillAppear(_ animated: Bool) {
        tableHeight.constant = view.frame.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageLookSegue" {
            let imageLookVC = segue.destination as? ImagePagerViewController
            imageLookVC?.userId = self.userId
            imageLookVC?.page = page
            imageLookVC?.data = data
            imageLookVC?.indexPath = sender as? IndexPath
        }
    }
}

extension Tab3ViewController {
    func fetchMoreData(){
        if !alreadyFetchingData {
            getUserImages()
        }
    }
    func getUserImages(){
        guard let userId = self.userId else {return}
        alreadyFetchingData = true
        Server.get("/user_images/\(userId)/\(page)/"){ data, response, error in
            self.alreadyFetchingData = false
            guard let data = data else {return}
            do {
                self.data.append(contentsOf: try JSONDecoder().decode([FoodPostImageObject].self, from: data))
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.page += 1
                    if self.data.count == 0 {
                        self.noMediaView.visibility = .visible
                    } else {
                        self.noMediaView.visibility = .invisible
                    }
                }
            } catch {}
        }
    }
}

extension Tab3ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tab3CollectionCell", for: indexPath) as! Tab3CollectionViewCell
        cell.foodImage.loadImageUsingUrlString(urlString: data[indexPath.row].food_photo_)
        cell.backgroundColor = UIColor.red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ImageLookSegue", sender: indexPath)
    }
}
