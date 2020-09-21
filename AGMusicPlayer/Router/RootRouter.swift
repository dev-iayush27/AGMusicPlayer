//
//  RootRouter.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 12/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
import UIKit

enum Destination {
    case splash
    case multiSongPlayer
}

public class RootRouter {
    public init() {}
    
    func showRootScreen() {
        let viewController = makeViewController(for: Destination.splash, bundle: [:])
        showViewController(viewController, inWindow: AppDelegate.currentWindow)
    }
    
    func showViewController(_ viewController: UIViewController, inWindow: UIWindow) {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        inWindow.rootViewController = navigationController
        inWindow.makeKeyAndVisible()
    }
    
    func navigate(to destination: Destination, bundle: [String: Any], type: Int = 0) {
        if let topViewController = UIApplication.topViewController() {
            switch type {
            case 1:
                let viewController = makeViewController(for: destination, bundle: bundle)
                topViewController.navigationController?.pushViewController(viewController, animated: false)
            case 2:
                let viewController = makeViewController(for: destination, bundle: bundle)
                viewController.modalPresentationStyle = .overCurrentContext
                topViewController.present(viewController, animated: true, completion: nil)
            case 3:
                let viewController = makeViewController(for: destination, bundle: bundle)
                viewController.modalPresentationStyle = .overCurrentContext
                topViewController.present(viewController, animated: false, completion: nil)
            default:
                let viewController = makeViewController(for: destination, bundle: bundle)
                topViewController.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    private func makeViewController(for destination: Destination, bundle: [String: Any]) -> UIViewController {
        switch destination {
        case .splash:
            return SplashRouter.assembleModule(bundle: bundle)
        case .multiSongPlayer:
            return MultiSongPlayerRouter.assembleModule(bundle: bundle)
        }
    }
}
