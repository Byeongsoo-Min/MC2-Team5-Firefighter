//
//  SplashViewController.swift
//  Manito
//
//  Created by SHIN YOON AH on 2022/06/16.
//

import UIKit

import Gifu

final class SplashViewController: BaseViewController {

    // MARK: - property
    
    @IBOutlet weak var gifImageView: GIFImageView!
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGifImage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.pushView()
        }
    }
    
    // MARK: - func
    
    @objc func pushView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController")
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        present(viewController, animated: true, completion: nil)
    }
    
    private func setupGifImage() {
        DispatchQueue.main.async {
            self.gifImageView.animate(withGIFNamed: ImageLiterals.gifLogo, animationBlock: nil)
        }
    }
}
