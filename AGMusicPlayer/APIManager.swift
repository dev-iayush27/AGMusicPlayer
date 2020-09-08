//
//  APIManager.swift
//  SwipeableCards
//
//  Created by Ayush Gupta on 09/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
import Alamofire

class APIManager: NSObject {
    
    class func getData(url: String, success: @escaping (_ response: SongResults) -> (), failure: @escaping (_ errorMessage: Error) -> ()) {
        AF.request(url, method: .get)
            .validate()
            .responseJSON { (response) in
                print(response)
                guard response.error == nil else {
                    print("error calling on \(url)")
                    return
                }
                guard let data = response.data else {
                    print("there was an error with the data")
                    return
                }
                do {
                    let model = try JSONDecoder().decode(SongResults.self, from: data)
                    success(model)
                } catch let jsonErr {
                    print("failed to decode, \(jsonErr.localizedDescription)")
                    failure(jsonErr)
                }
        }
    }
}
