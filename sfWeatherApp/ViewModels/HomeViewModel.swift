//
//  WeatherMainViewModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct HomeViewModelData {
    var cityName:String
    var weather:String
    var temperature:Float
    var errorMessage:String
    var isLoading:Bool
    
    init() {
        cityName = "--"
        weather = "--"
        temperature = Float.nan
        errorMessage = ""
        isLoading = false
    }
    
    mutating func update(weatherResult: OWWeatherResult, isLoading: Bool) {
        cityName = weatherResult.name
        weather = weatherResult.weather[0].main // danger code...
        temperature = weatherResult.main.temp
        
        self.isLoading = isLoading
    }
    
    mutating func update(isLoading: Bool, errorMessage: String) {
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }
    
    func getFormattedTemperatureText() -> String {
        if (temperature.isNaN) {
            return "--°"
        }
        
        let mTemp = (temperature - 273.15);
        
        return "\(String(format: "%.1f", mTemp))°";
    }
}

class HomeViewModel {
    var owService:OWService
    var searchHistoryRepo:SearchHistoryRepository
    
    var data:Dynamic<HomeViewModelData>
    
    init(owService: OWService, searchHistoryRepo:SearchHistoryRepository) {
        self.owService = owService
        self.searchHistoryRepo = searchHistoryRepo
        
        data = Dynamic(HomeViewModelData())
    }
    
    func fetchDefaultWeather() {
        do {
            if let searchHistory = try searchHistoryRepo.findLatest() {
                let fetchType:OWFetchCurrentWeatherType = .byCityId(cityId: searchHistory.cityId)
                self.fetchCurrentWeather(fetchType)
            }
        } catch {
            print("WeatherHomeViewModel - fetchDefaultWeather - error")
            print(error)
        }
    }
    
    func fetchCurrentWeather(_ fetchType: OWFetchCurrentWeatherType) {
        print("WeatherHomeViewModel - fetchWeather")
        
        self.data.value.update(isLoading: true, errorMessage: "")
        
        // to do error handling
        owService.fetchCurrentWeather(fetchType: fetchType, success: {  [weak self] weatherResult in
            guard let strongSelf = self else { return }

            print("WeatherHomeViewModel - fetchWeather - success")
            
            // update data
            strongSelf.data.value.update(weatherResult: weatherResult, isLoading: false)
            
            // insert search history
            strongSelf.insertSearchHistory(weatherResult: weatherResult)
        }, failure: { [weak self] error in
            guard let strongSelf = self else { return }

            print("WeatherHomeViewModel - fetchWeather - error")
            
            var errorMessage:String;
            
            switch error {
            case OWServiceError.clientError(let errorResponse):
                //strongSelf.errorMessage.value = errorResponse.message
                errorMessage = errorResponse.message
                break
            default:
                //strongSelf.errorMessage.value = "Unknown error"
                errorMessage = "Unknown error"
                break
            }
            
            strongSelf.data.value.update(isLoading: false, errorMessage: errorMessage)
        })
    }
    
    private func insertSearchHistory(weatherResult: OWWeatherResult) {
        let searchHistory = SearchHistory(cityId: weatherResult.id, cityName: weatherResult.name, timestamp: Date().currentTimestamp())
        
        do {
            _ = try self.searchHistoryRepo.delete(searchHistory)
            _ = try self.searchHistoryRepo.insert(searchHistory)
        } catch {
            print("WeatherHomeViewModel - insertSearchHistory - error")
            print(error)
        }
    }
}
