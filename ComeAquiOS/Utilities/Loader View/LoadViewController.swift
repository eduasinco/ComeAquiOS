//
//  LoadViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {
    var loaderVC: UIViewController!
    var transparentLoaderVC: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loaderVC = addLoader(storyBoardString: "LoadingStoryboard", storyBoardIdentifier: "LoadingView")
        transparentLoaderVC = addLoader(storyBoardString: "TansparentLoaderStoryboard", storyBoardIdentifier: "LoadingView")
    }
    
    func addLoader(storyBoardString: String, storyBoardIdentifier: String) -> UIViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: storyBoardString, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: storyBoardIdentifier)
        vc.modalPresentationStyle = .overCurrentContext
        addChild(vc)
        view.addSubview(vc.view)
        view.bringSubviewToFront(vc.view)
        vc.view.isHidden = true
        setContraints(vc.view)
        return vc
    }
    
    func setContraints(_ childView: UIView) {
        childView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        childView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        childView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        childView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    }
    
    func presentLoader(){
        loaderVC.view.isHidden = false
    }
    func closeLoader() {
        DispatchQueue.main.async {
            self.loaderVC.view.isHidden = true
        }
    }
    
    func presentTransparentLoader(){
        transparentLoaderVC.view.isHidden = false
    }
    func closeTransparentLoader() {
        DispatchQueue.main.async {
            self.transparentLoaderVC.view.isHidden = true
        }
    }
}
