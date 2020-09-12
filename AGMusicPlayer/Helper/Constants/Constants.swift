//
//  Constants.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 11/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation

struct Constants {
    
    struct URLs {
        static let base_url = "https://itunes.apple.com"
    }
    
    struct UserDefaults {
        static let token = "token"
    }
    
    struct ApiConstants {
        static let term = "term"
        static let media = "media"
        static let entity = "entity"
    }
    
    struct ApiPathConstants {
        static let search = "/search"
    }
    
    struct BundleConstants {
        static let delegate = "delegate"
        static let songData = "songData"
        static let resultData = "resultData"
    }
    
    struct CommonConstants {
        static let whiteSpaceAlternative = "{@}"
    }
}
