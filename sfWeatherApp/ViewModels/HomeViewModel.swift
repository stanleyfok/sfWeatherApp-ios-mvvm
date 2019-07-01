//
//  WeatherMainViewModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct HomeViewModelData {
    var weatherResult:OWWeatherResult?
    var errorMessage:String = ""
    var isLoading:Bool = false

    mutating func update(weatherResult: OWWeatherResult, isLoading: Bool) {
        self.weatherResult = weatherResult
        self.isLoading = isLoading
    }

    mutating func update(isLoading: Bool, errorMessage: String) {
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }
    
    func getCityNameText() -> String {
        if let cityName = weatherResult?.name {
            return cityName
        }
        
        return "--"
    }
    
    func getWeatherText() -> String {
        if let weather = weatherResult?.weather[0].main  {
            return weather
        }
        
        return "--"
    }

    func getTemperatureText() -> String {
        if let temperature = weatherResult?.main.temp {
            if (temperature.isNaN) {
                return "--°"
            }

            let mTemp = (temperature - 273.15);

            return "\(String(format: "%.1f", mTemp))°";
        }
        
        return "--°"
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
}


// MARK: current weather fetching

extension HomeViewModel {
    func fetchDefaultWeather() {
        do {
            if let searchHistory = try searchHistoryRepo.findLatest() {
                self.fetchCurrentWeather(cityId: searchHistory.cityId);
            }
        } catch {
            print("WeatherHomeViewModel - fetchDefaultWeather - error")
            print(error)
        }
    }
    
    func fetchCurrentWeather(cityId: Int) {
        print("WeatherHomeViewModel - fetchCurrentWeather - start")
        
        self.data.value.update(isLoading: true, errorMessage: "")
        
        // to do error handling
        owService.fetchCurrentWeather(fetchType: OWFetchCurrentWeatherType.byCityId(cityId: cityId), success: fetchCurrentWeatherSuccessHandler(), failure: fetchCurrentWeatherFailureHandler())
    }
    
    func fetchCurrentWeather(cityName: String) {
        print("WeatherHomeViewModel - fetchCurrentWeather - start")
        
        self.data.value.update(isLoading: true, errorMessage: "")
        
        // to do error handling
        owService.fetchCurrentWeather(fetchType: OWFetchCurrentWeatherType.byCityName(cityName: cityName), success: fetchCurrentWeatherSuccessHandler(), failure: fetchCurrentWeatherFailureHandler())
    }
    
    func fetchCurrentWeather(lat: Float, lon:Float) {
        print("WeatherHomeViewModel - fetchCurrentWeather - start")
        
        self.data.value.update(isLoading: true, errorMessage: "")
        
        // to do error handling
        owService.fetchCurrentWeather(fetchType: OWFetchCurrentWeatherType.byCoordinates(lat: lat, lon: lon), success: fetchCurrentWeatherSuccessHandler(), failure: fetchCurrentWeatherFailureHandler())
    }
    
    private func fetchCurrentWeatherSuccessHandler() -> (OWWeatherResult) -> Void {
        return {  [weak self] weatherResult in
            guard let strongSelf = self else { return }
            
            print("WeatherHomeViewModel - fetchCurrentWeather - success")
            
            // update data
            strongSelf.data.value.update(weatherResult: weatherResult, isLoading: false)
            
            // insert search history
            strongSelf.insertSearchHistory(weatherResult: weatherResult)
        }
    }
    
    private func fetchCurrentWeatherFailureHandler() -> (Error) -> Void {
        return { [weak self] error in
            guard let strongSelf = self else { return }
            
            print("WeatherHomeViewModel - fetchCurrentWeather - error")
            
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
        }
    }
}

// MARK: search history handling

extension HomeViewModel {
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
