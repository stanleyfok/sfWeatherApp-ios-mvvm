//
//  OpenWeatherService.swift
//  sfWeatherApp
//
//  Created by Stanley Fok on 9/11/2019.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

enum OpenWeatherNetworkResponse {
    case success
    case failure(_ error: OpenWeatherError)
}

enum OpenWeatherError {
    case networkError
    case noDataError
    case decodingError
    case knownError
    case unknownError
}

struct OpenWeatherService {
    let router = Router<OpenWeatherApi>()

    func findByCityName(_ cityName: String, success: @escaping (_ weatherResult: OWWeatherResult) -> Void, failure: @escaping (_ error: OpenWeatherError, _ errorResult: OWErrorResult?) -> Void) {
        
        self.handleRequest(OpenWeatherApi.fetchWeatherByCityName(cityName), OWWeatherResult.self, success, failure)
    }
    
    func findByCityId(_ cityId: Int, success: @escaping (_ weatherResult: OWWeatherResult) -> Void, failure: @escaping (_ error: OpenWeatherError, _ errorResult: OWErrorResult?) -> Void) {
        
        self.handleRequest(OpenWeatherApi.fetchWeatherByCityId(cityId), OWWeatherResult.self, success, failure)
    }
}

extension OpenWeatherService {
    fileprivate func getNetworkResponse(_ response: HTTPURLResponse) -> OpenWeatherNetworkResponse {
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(OpenWeatherError.knownError)
        case 501...599: return .failure(OpenWeatherError.knownError)
        default: return .failure(OpenWeatherError.unknownError)
        }
    }
    
    fileprivate func handleRequest<T>(_ weatherApi: OpenWeatherApi, _ type: T.Type, _ success: @escaping (_ result: T) -> Void, _ failure: @escaping (_ error: OpenWeatherError, _ errorResult: OWErrorResult?) -> Void) where T : Decodable {
        router.request(weatherApi) { data, response, error in
              guard error == nil else {
                  failure(.networkError, nil)
                  
                  return
              }
              
              guard let responseData = data else {
                  failure(.noDataError, nil)
                  return
              }
              
              if let response = response as? HTTPURLResponse {
                  let networkResponse = self.getNetworkResponse(response)
                  
                  switch networkResponse {
                  case .success:
                      do {
                          let result = try JSONDecoder().decode(type, from: responseData)
                          success(result)
                      } catch {
                          failure(.decodingError, nil)
                      }
                  case .failure(let openWeatherError):
                      if (openWeatherError.self == .knownError) {
                          do {
                              let errorResult = try JSONDecoder().decode(OWErrorResult.self, from: responseData)
                              
                              failure(.knownError, errorResult)
                          } catch {
                              failure(.decodingError, nil)
                          }
                      } else {
                          failure(openWeatherError, nil)
                      }
                  }
              }
          }
    }
}
