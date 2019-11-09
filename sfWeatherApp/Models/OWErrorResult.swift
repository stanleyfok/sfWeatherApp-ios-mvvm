//
//  OWErrorResult.swift
//  sfWeatherApp
//
//  Created by Stanley Fok on 10/11/2019.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct OWErrorResult: Decodable {
    var code:String
    var message:String
    
    enum CodingKeys: String, CodingKey {
        case code = "cod" // rename
        case message
    }
}
