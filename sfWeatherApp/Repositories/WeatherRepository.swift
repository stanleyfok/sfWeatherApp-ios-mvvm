//
//  WeatherRepository.swift
//  sfWeatherApp
//
//  Created by Stanley Fok on 9/11/2019.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct WeatherRepository {
    let owService:OWService = OWService()
    let searchHistoryDAO:SearchHistoryDAO = SearchHistoryDAO()
    
    func findWeather(by cityName: String, success: @escaping (_ weatherResult: OWWeatherResult) -> Void, failure: @escaping (_ error: OWError, _ errorResult: OWErrorResult?) -> Void) {
        owService.findBy(cityName: cityName, success: success, failure: failure)
    }
    
    func findWeather(by cityId: Int, success: @escaping (_ weatherResult: OWWeatherResult) -> Void, failure: @escaping (_ error: OWError, _ errorResult: OWErrorResult?) -> Void) {
        owService.findBy(cityId: cityId, success: success, failure: failure)
    }
    
    func getAllHistories() throws -> Array<SearchHistory> {
        return try searchHistoryDAO.findAll()
    }
    
    func getLatestHistory() throws -> SearchHistory? {
        return try searchHistoryDAO.findLatest()
    }
    
    func insertHistory(_ searchHistory: SearchHistory) throws -> Int64? {
        return try searchHistoryDAO.insert(searchHistory)
    }
    
    func deleteHisoryByCityId(_ cityId: Int) throws -> Int? {
        return try searchHistoryDAO.deleteByCityId(cityId)
    }
}
