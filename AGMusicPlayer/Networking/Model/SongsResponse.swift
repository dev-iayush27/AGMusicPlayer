//
//  SongsResponse.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 09/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
import Mapper

struct SongsResponse: Mappable, Codable {
    var resultCount: Int?
    var results: [ResultData]?
    
    init(map: Mapper) throws {
        resultCount = map.optionalFrom("resultCount")
        results = map.optionalFrom("results")
    }
}

struct ResultData: Mappable, Codable {
    
    var artistID: Int?
    var artistName: String?
    var collectionName: String?
    var trackName: String?
    var previewUrl: String?
    var artworkUrl100: String?
    var releaseDate: String?
    var trackTimeMillis: Int?
    var isStreamable: Bool?
    
    init(map: Mapper) throws {
        artistID = map.optionalFrom("artistID")
        artistName = map.optionalFrom("artistName")
        collectionName = map.optionalFrom("collectionName")
        trackName = map.optionalFrom("trackName")
        previewUrl = map.optionalFrom("previewUrl")
        artworkUrl100 = map.optionalFrom("artworkUrl100")
        releaseDate = map.optionalFrom("releaseDate")
        trackTimeMillis = map.optionalFrom("trackTimeMillis")
        isStreamable = map.optionalFrom("isStreamable")
    }
}
