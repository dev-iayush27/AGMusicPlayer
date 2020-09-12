import Foundation
import Disk

struct APICacheManager {
    // Function to perform api cache logics
    // responseName: (eg: SongResults.json)
    // resoponseType: (eg: SongResults.self)
    static func checkApiCacheAvailable<T>(responseName: String, responseType: T.Type, completion: (Bool, T?) -> Void) where T: Codable {
        var completeionValues: (Bool, T?) = (false, nil)
        if let apiResponse = try? Disk.retrieve(responseName, from: .caches, as: responseType) {
            completeionValues = (true, apiResponse)
        }
        completion(completeionValues.0, completeionValues.1)
    }
    
    // Function to save Api response into cache
    static func saveApiCacheResponse<T>(responseName: String, responseType: T.Type, apiResponse: T) where T: Codable  {
        try? Disk.save(apiResponse, to: .caches, as: responseName)
    }
}
