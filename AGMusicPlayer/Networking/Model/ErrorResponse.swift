//
//  ErrorResponse.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 13/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
import Mapper

struct ErrorResponse: Mappable {
    var error: ErrorResponseData?

    init(map: Mapper) throws {
        error = map.optionalFrom("error")
    }
}

struct ErrorResponseData: Mappable {
    var status: Int?
    var message: String?
    var reason: String?

    init(map: Mapper) throws {
        status = map.optionalFrom("status") ?? 400
        message = map.optionalFrom("message") ?? ""
        reason = map.optionalFrom("reason") ?? ""
    }
}
