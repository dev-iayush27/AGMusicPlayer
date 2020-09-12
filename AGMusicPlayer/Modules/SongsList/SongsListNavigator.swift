//
//  SongsListNavigator.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 12/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
import UIKit

class SongsListNavigator {
    
    static func songsListModule(bundle: [String: Any]) -> UIViewController {
        let vc = SongsListVC(nibName: "SongsListVC", bundle: nil)
        vc.bundle = bundle
        return vc
    }
    
    func navigateTo(destination: Destination, bundle: [String: Any], type: Int = 0) {
        RootNavigator().navigate(to: destination, bundle: bundle, type: type)
    }
}
