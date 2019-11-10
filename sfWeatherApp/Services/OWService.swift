//
//  OWService.swift
//  sfWeatherApp
//
//  Created by Stanley Fok on 9/11/2019.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

enum OWNetworkResponse {
    case success
    case failure(_ error: OWError)
}

enum OWError {
    case networkError
    case noDataError
    case decodingError
    case knownError
    case unknownError
}

class OWService {
    let router = Router<OWApi>()

    func findBy(cityName: String, success: @escaping (_ weatherResult: OWWeatherResult) -> Void, failure: @escaping (_ error: OWError, _ errorResult: OWErrorResult?) -> Void) {
        
        self.handleRequest(OWApi.fetchWeatherByCityName(cityName), OWWeatherResult.self, success, failure)
    }
    
    func findBy(cityId: Int, success: @escaping (_ weatherResult: OWWeatherResult) -> Void, failure: @escaping (_ error: OWError, _ errorResult: OWErrorResult?) -> Void) {
        
        self.handleRequest(OWApi.fetchWeatherByCityId(cityId), OWWeatherResult.self, success, failure)
    }
}

extension OWService {
    fileprivate func getNetworkResponse(_ response: HTTPURLResponse) -> OWNetworkResponse {
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(OWError.knownError)
        case 501...599: return .failure(OWError.knownError)
        default: return .failure(OWError.unknownError)
        }
    }
    
    fileprivate func handleRequest<T>(_ weatherApi: OWApi, _ type: T.Type, _ success: @escaping (_ result: T) -> Void, _ failure: @escaping (_ error: OWError, _ errorResult: OWErrorResult?) -> Void) where T : Decodable {
        self.router.request(weatherApi) { data, response, error in
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
                  case .failure(let owError):
                      if (owError.self == .knownError) {
                          do {
                              let errorResult = try JSONDecoder().decode(OWErrorResult.self, from: responseData)
                              
                              failure(.knownError, errorResult)
                          } catch {
                              failure(.decodingError, nil)
                          }
                      } else {
                          failure(owError, nil)
                      }
                  }
              }
          }
    }
}
