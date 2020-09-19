//
//  TimeIntervel+Extension.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 19/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation

extension TimeInterval {
    var minuteSecondMS: String {
        return String(format:"%d:%02d", minute, second)
    }
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
}

extension Int {
    var msToSeconds: Double {
        return Double(self) / 1000
    }
}
