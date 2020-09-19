//
//  NetworkTarget.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 13/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
import Moya

enum NetworkTarget {
    case searchByQuery(parameters: [String: Any])
    case getAlbum(parameters: [String: Any])
}

extension NetworkTarget: NetworkTargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var baseURL: URL {
        return URL(string: Constants.URLs.base_url)!
    }
    
    var path: String {
        switch self {
        case .searchByQuery:
            return Constants.ApiPathConstants.search
        case .getAlbum:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchByQuery:
            return .get
        case .getAlbum:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case let .searchByQuery(parameters):
            return parameters
        case let .getAlbum(parameters):
            return parameters
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    var task: Task {
        switch self {
        default:
            switch method {
            case .get:
                return Task.requestParameters(parameters: parameters!, encoding: URLEncoding.default)
            default:
                return Task.requestParameters(parameters: parameters!, encoding: JSONEncoding.default)
            }
        }
    }
}
