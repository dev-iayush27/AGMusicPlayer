//
//  SongModel.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 09/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation

struct SongResults: Codable {
    var resultCount: Int?
    var results: [ResultData]?
}

struct ResultData: Codable {
    var artistID: Int?
    var artistName: String?
    var collectionName: String?
    var trackName: String?
    var previewURL: String?
    var artworkUrl100: String?
    var releaseDate: String?
    var trackTimeMillis: Int?
    var isStreamable: Bool?
}
