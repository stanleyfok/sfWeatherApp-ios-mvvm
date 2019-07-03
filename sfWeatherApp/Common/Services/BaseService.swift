//
//  BaseService.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

enum BaseServiceResponse {
    case success(data: Data, response: URLResponse)
    case failure(error: Error)
}

enum BaseServiceError: Error {
    case clientError(statusCode: Int, data: Data, response: URLResponse)
    case serverError(statusCode: Int, data: Data, response: URLResponse)
    case noDataError
}

class BaseService {
    func callEndpoint(request: URLRequest, completion: @escaping (BaseServiceResponse) -> Void) {
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            // check for error
            guard error == nil else {
                completion(.failure(error: error!))
                
                return
            }
            
            // check for data available
            guard data != nil else {
                completion(.failure(error: BaseServiceError.noDataError))
                
                return
            }
            
            // check for status code
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                switch httpResponse.statusCode {
                case 400...499:
                    completion(.failure(error: BaseServiceError.clientError(statusCode: statusCode, data: data!, response: response!)))
                    
                    return
                case 500...599:
                    completion(.failure(error: BaseServiceError.serverError(statusCode: statusCode, data: data!, response: response!)))
                
                    return
                default:
                    break
                }
                
            }
            
            completion(.success(data: data!, response: response!))
        })
        
        task.resume()
    }
}
