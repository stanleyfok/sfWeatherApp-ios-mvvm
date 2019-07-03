//
//  OWService.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

enum OWServiceResponse {
    case success(_ result:Decodable)
    case failure(_ error:OWServiceError)
}

enum OWServiceError: Error {
    case generalError(_ errorResponse: OWErrorResult)
    case decodingError
    case unknownError
}

enum OWFetchCurrentWeatherType {
    case byCityName(cityName: String)
    case byCityId(cityId: Int)
    case byCoordinates(lat: Float, lon: Float)
}

class OWService:BaseService {
    let baseURL = "https://api.openweathermap.org/data/2.5";
    let appIdQueryItem = URLQueryItem(name: "appid", value: "95d190a434083879a6398aafd54d9e73");
    
    public func fetchCurrentWeather(fetchType: OWFetchCurrentWeatherType, completionHandler: @escaping (OWServiceResponse) -> Void) {
        var urlComponents = URLComponents(string: "\(baseURL)/weather")!
        
        switch fetchType {
        case .byCityName(let cityName):
            urlComponents.queryItems = [
                URLQueryItem(name: "q", value: cityName),
            ]
            break
        case .byCityId(let cityId):
            urlComponents.queryItems = [
                URLQueryItem(name: "id", value: String(cityId)),
            ]
            break
        case .byCoordinates(let lat, let lon):
            urlComponents.queryItems = [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon)),
            ]
            break
        }
        
        urlComponents.queryItems?.append(appIdQueryItem)
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        
        requestHandler(request, OWWeatherResult.self, completionHandler)
    }
}

extension OWService {
    private func requestHandler<T>(_ request: URLRequest, _ type: T.Type, _ completionHandler: @escaping (OWServiceResponse) -> Void) where T : Decodable {
        var mRequest = request;
        mRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        self.callEndpoint(request: mRequest) { serviceResponse in
            DispatchQueue.global(qos: .background).async {
                switch serviceResponse {
                case .success(let data, _):
                    do {
                        let result = try JSONDecoder().decode(type, from: data)
                        
                        completionHandler(.success(result))
                    } catch let decodeErr{
                        print(decodeErr)
                        completionHandler(.failure(.decodingError))
                    }
                    break
                case .failure(let error):
                    switch error {
                    case BaseServiceError.clientError( _, let data, _):
                        do {
                            let errorResult = try JSONDecoder().decode(OWErrorResult.self, from: data)
                            
                            completionHandler(.failure(.generalError(errorResult)))
                        } catch {
                            completionHandler(.failure(.decodingError))
                        }
                        break
                    case BaseServiceError.serverError( _, let data, _):
                        do {
                            let errorResult = try JSONDecoder().decode(OWErrorResult.self, from: data)
                            
                            completionHandler(.failure(.generalError(errorResult)))
                        } catch {
                            completionHandler(.failure(.decodingError))
                        }
                        break
                    default:
                        completionHandler(.failure(.unknownError))
                        break
                    }
                }
            }
        }
    }
}
