//
//  WeatherRepository.swift
//  sfWeatherApp
//
//  Created by Stanley Fok on 9/11/2019.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct WeatherRepository {
    let owService:OpenWeatherService = OpenWeatherService()
    let searchHistoryDAO:SearchHistoryDAO = SearchHistoryDAO()
    
    func findWeatherByCityName(_ cityName: String, success: @escaping (_ weatherResult: OWWeatherResult) -> Void, failure: @escaping (_ error: OpenWeatherError, _ errorResult: OWErrorResult?) -> Void) {
        owService.findByCityName(cityName, success: success, failure: failure)
    }
    
    func findWeatherByCityId(_ cityId: Int, success: @escaping (_ weatherResult: OWWeatherResult) -> Void, failure: @escaping (_ error: OpenWeatherError, _ errorResult: OWErrorResult?) -> Void) {
        owService.findByCityId(cityId, success: success, failure: failure)
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
