//
//  UIViewController+Extension.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 19/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func getTime(time: TimeInterval) -> String {
        let duration = Int(time)
        let min = duration/60
        let sec = duration - min * 60
        let totalDuration = String(format: "%02d:%02d", min, sec)
        return totalDuration
    }
}
