//
//  APIManager.swift
//  SwipeableCards
//
//  Created by Ayush Gupta on 09/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
//import Alamofire
import Moya

final class APIManager: NSObject {
    
    static let provider = MoyaProvider<APIManagerTarget>()
    
    static func request<T: Decodable>(target: APIManagerTarget, responseType: T.Type, onSuccess: @escaping (T?) -> (), onFailure: @escaping (Error) -> ()) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        provider.request(target) { (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            AppDelegate.finishLoading()
            switch result {
            case .success(let response):
                if response.statusCode >= 200 && response.statusCode <= 300 {
                    do {
                        let result = try JSONDecoder().decode(T.self, from: response.data)
                        onSuccess(result)
                    } catch let jsonErr {
                        print("failed to decode, \(jsonErr.localizedDescription)")
                        onFailure(jsonErr)
                    }
                } else {
                    let error = NSError(domain: "com.vsemenchenko.networkLayer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Parsing Error"])
                    onFailure(checkFailureError(error))
                }
            case .failure(let error):
                onFailure(error)
            }
        }
    }
    
    //    func fetch<T: Decodable>(responseType: T.Type, endPoint: String, apiName: APIName, parameters: [String: Any], onCompletion: @escaping (T?, Error?, Int) -> ()) {
    //        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    //        AF.request(baseURL + endPoint, method: method, parameters: parameters, encoding: encoding, headers: headers)
    //            .validate()
    //            .responseJSON { (response) in
    //                UIApplication.shared.isNetworkActivityIndicatorVisible = false
    //                if response.error != nil || response.data == nil {
    //                    onCompletion(T.self as? T, response.error, (response.response?.statusCode)!)
    //                    return
    //                }
    //                do {
    //                    let result = try JSONDecoder().decode(T.self, from: response.data!)
    //                    onCompletion(result, response.error, (response.response?.statusCode)!)
    //                } catch let jsonErr {
    //                    print("failed to decode, \(jsonErr.localizedDescription)")
    //                    onCompletion(T.self as? T, jsonErr, (response.response?.statusCode)!)
    //                }
    //        }
    //    }
}
