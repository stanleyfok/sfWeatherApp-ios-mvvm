//
//  OWService.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

enum OWServiceError: Error {
    case clientError(errorResponse: OWErrorResult)
    case serverError(errorResponse: OWErrorResult)
}

class OWService:BaseService {
    let baseURL = "https://api.openweathermap.org/data/2.5";
    let appIdQueryItem = URLQueryItem(name: "appid", value: "95d190a434083879a6398aafd54d9e73");
    
    public func fetchWeatherByCityName(_ cityName: String, success: @escaping (OWWeatherResult) -> Void, failure: @escaping (Error) -> Void) {
        var urlComponents = URLComponents(string: "\(baseURL)/weather")!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: cityName),
            appIdQueryItem
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        
        requestHandler(request, OWWeatherResult.self, success, failure)
    }
}

extension OWService {
    private func requestHandler<T>(_ request: URLRequest, _ type: T.Type, _ success: @escaping (T) -> Void, _ failure: @escaping (Error) -> Void) where T : Decodable {
        var mRequest = request;
        mRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        self.callEndpoint(request: mRequest) { serviceResponse in
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let strongSelf = self else { return }
                
                switch serviceResponse {
                case .success(let data, _):
                    strongSelf.decodeHandler(type, from: data, decodeSuccess: success, decodeFailure: failure)
                    break
                case .failure(let error):
                    strongSelf.errorHandler(error: error, failure: failure)
                }
            }
        }
    }
    
    private func decodeHandler<T>(_ type: T.Type, from data: Data, decodeSuccess: @escaping (T) -> Void, decodeFailure: @escaping (Error) -> Void) where T : Decodable {
        do {
            let result = try JSONDecoder().decode(type, from: data)
            
            decodeSuccess(result)
        } catch let decodingError{
            decodeFailure(decodingError)
        }
    }
    
    private func errorHandler(error: Error, failure: @escaping (Error) -> Void) {
        switch error {
        case BaseServiceError.clientError(_, let data, _):
            self.decodeHandler(OWErrorResult.self, from: data, decodeSuccess: { (errorResult) in
                failure(OWServiceError.clientError(errorResponse: errorResult))
            }, decodeFailure: failure)
            
            break
        case BaseServiceError.serverError(_, let data, _):
            self.decodeHandler(OWErrorResult.self, from: data, decodeSuccess: { (errorResult) in
                failure(OWServiceError.serverError(errorResponse: errorResult))
            }, decodeFailure: failure)
            
            break
        default:
            failure(error)
            break
        }
    }
}
