//
//  SongModel.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 09/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation

struct DataResult {
    let id: String
    let text: String
}

extension DataResult {
    static func getAllData() -> [DataResult] {
        return [
            DataResult(id: "1", text: "Charlie Puth - Nine Track Mind"),
            DataResult(id: "2", text: "Ayush Gupta - Four Track Mind"),
            DataResult(id: "3", text: "Atif Aslam - Six Track Mind")
        ]
    }
}
