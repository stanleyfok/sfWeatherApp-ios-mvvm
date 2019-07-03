//
//  BaseService.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

enum BaseServiceResponse {
    case success(_ data: Data, _ response: URLResponse)
    case failure(_ error: Error)
}

enum BaseServiceError: Error {
    case clientError(_ statusCode: Int, _ data: Data, _ response: URLResponse)
    case serverError(_ statusCode: Int, _ data: Data, _ response: URLResponse)
    case noDataError
    case unknownError
}

class BaseService {
    func callEndpoint(request: URLRequest, completion: @escaping (BaseServiceResponse) -> Void) {
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            // check for error
            guard error == nil else {
                completion(.failure(error!))
                
                return
            }
            
            // check for data available
            guard data != nil else {
                completion(.failure(BaseServiceError.noDataError))
                
                return
            }
            
            // check for status code
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                switch httpResponse.statusCode {
                case 200...299:
                    completion(.success(data!, response!))

                    break
                case 400...499:
                    completion(.failure(BaseServiceError.clientError(statusCode, data!, response!)))
                    break
                case 500...599:
                    completion(.failure(BaseServiceError.serverError(statusCode, data!, response!)))
                    break
                default:
                    completion(.failure(BaseServiceError.unknownError))
                    break
                }
            }
            
        })
        
        task.resume()
    }
}
