//
//  LoadViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 22/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {
    var loaderVC: LoadingViewController?
    var transparentLoaderVC: TransparentLoaderViewController?
    var reloadVC: ReloadViewController?
    var reloadViewOpacity: CGFloat = 0.5
    var onReload: (() -> Void)? {
        willSet {
            DispatchQueue.main.async {
                self.reloadVC?.view.showToast(message: "No internet connection")
                self.reloadVC?.view.isHidden = false
            }
            reloadVC?.onReload = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loaderVC = addLoader(storyBoardString: "LoadingStoryboard", storyBoardIdentifier: "LoadingView") as? LoadingViewController
        transparentLoaderVC = addLoader(storyBoardString: "TansparentLoaderStoryboard", storyBoardIdentifier: "LoadingView") as? TransparentLoaderViewController
        
        reloadVC = addLoader(storyBoardString: "ReloadStoryboard", storyBoardIdentifier: "ReloadView") as? ReloadViewController
        reloadVC?.view?.backgroundColor = UIColor(white: 1, alpha: self.reloadViewOpacity)
    }
    
    func addLoader(storyBoardString: String, storyBoardIdentifier: String) -> UIViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: storyBoardString, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: storyBoardIdentifier)
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
        loaderVC?.view.isHidden = false
    }
    func closeLoader() {
        DispatchQueue.main.async {
            self.loaderVC?.view.isHidden = true
        }
    }
    
    func presentTransparentLoader(){
        transparentLoaderVC?.view.isHidden = false
    }
    func closeTransparentLoader() {
        DispatchQueue.main.async {
            self.transparentLoaderVC?.view.isHidden = true
        }
    }
}

extension LoadViewController {
    @IBInspectable var reloadOpacity: CGFloat {
        set {
            self.reloadViewOpacity = newValue
        }
        get{
            return 0.5
        }
    }
}
