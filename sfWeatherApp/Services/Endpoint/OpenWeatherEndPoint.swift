//
//  OpenWeatherEndPoint.swift
//  sfWeatherApp
//
//  Created by Stanley Fok on 9/11/2019.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

public enum OpenWeatherApi {
    case fetchWeatherByCityName(_ cityName: String)
    case fetchWeatherByCityId(_ cityId: Int)
}

extension OpenWeatherApi: EndPointType {
    var baseURL: URL {
        return URL(string: "https://api.openweathermap.org/data/2.5/")!
    }
    
    var appId: String {
        return "95d190a434083879a6398aafd54d9e73"
    }
    
    var path: String {
         switch self {
         case .fetchWeatherByCityId,
              .fetchWeatherByCityName:
             return "weather"
         }
     }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .fetchWeatherByCityName(let cityName):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["q": cityName,
                                                      "appid": appId])
        case .fetchWeatherByCityId(let cityId):
            return .requestParameters(bodyParameters: nil,
                                  bodyEncoding: .urlEncoding,
                                  urlParameters: ["id": cityId,
                                                  "appid": appId])
//        default:
//            return .request
        }
    }
    
    var headers: HTTPHeaders? {
       return nil
   }
}
