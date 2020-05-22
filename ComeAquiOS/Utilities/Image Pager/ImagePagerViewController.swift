//
//  ImagePagerViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 11/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class ImagePagerViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var data: [FoodPostImageObject] = []
    var userId: Int?
    var indexPath: IndexPath?
    
    var page: Int = 1
    var alreadyFetchingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
                
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        getUserImages()
    }
    override func viewDidLayoutSubviews() {
        guard self.indexPath != nil else {return}
        self.collectionView.scrollToItem(at: self.indexPath!, at: .right, animated: false)
    }
}

extension ImagePagerViewController {
    func fetchMoreData(){
        if !alreadyFetchingData {
            getUserImages()
        }
    }
    func getUserImages(){
        guard let userId = self.userId else {return}
        alreadyFetchingData = true
        Server.get("/user_images/\(userId)/\(page)/", finish: {(data: Data?, response: URLResponse?) -> Void in
            self.alreadyFetchingData = false
            guard let data = data else {return}
            do {
                self.data.append(contentsOf: try JSONDecoder().decode([FoodPostImageObject].self, from: data))
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.collectionView.scrollToItem(at: self.indexPath!, at: .right, animated: false)
                    self.page += 1
                }
            } catch {}
        })
    }
}

extension ImagePagerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePagerCell", for: indexPath) as! ImagePagerCollectionViewCell
        cell.image.loadImageUsingUrlString(urlString: data[indexPath.row].food_photo)
        cell.backgroundColor = UIColor.red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
}
