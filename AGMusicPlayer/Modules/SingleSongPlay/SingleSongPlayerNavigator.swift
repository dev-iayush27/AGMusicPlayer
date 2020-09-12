//
//  SingleSongPlayerNavigator.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 12/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
import UIKit

class SingleSongPlayerNavigator {
    
    static func singleSongPlayerModule(bundle: [String: Any]) -> UIViewController {
        let vc = SingleSongPlayerVC(nibName: "SingleSongPlayerVC", bundle: nil)
        vc.bundle = bundle
        return vc
    }
    
    func navigateTo(destination: Destination, bundle: [String: Any], type: Int = 0) {
        RootNavigator().navigate(to: destination, bundle: bundle, type: type)
    }
}
