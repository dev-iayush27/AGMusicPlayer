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

// MARK: - SongResults
struct SongResults: Codable {
    let resultCount: Int
    let results: [ResultData]
}

// MARK: - Result
struct ResultData: Codable {
    let wrapperType: String?
    let kind: String?
    let artistID: Int?
    let collectionID: Int?
    let trackID: Int?
    let artistName: String?
    let collectionName: String?
    let trackName: String?
    let collectionCensoredName: String?
    let trackCensoredName: String?
    let artistViewURL: String?
    let collectionViewURL: String?
    let trackViewURL: String?
    let previewURL: String?
    let artworkUrl30, artworkUrl60, artworkUrl100: String?
    let collectionPrice, trackPrice: Double?
    let releaseDate: String?
    let collectionExplicitness, trackExplicitness: String?
    let discCount, discNumber, trackCount, trackNumber: Int?
    let trackTimeMillis: Int?
    let country: String?
    let currency: String?
    let primaryGenreName: String?
    let isStreamable: Bool?
    let collectionArtistID: Int?
    let collectionArtistName, contentAdvisoryRating: String?
}
