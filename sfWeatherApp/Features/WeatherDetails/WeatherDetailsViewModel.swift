//
//  WeatherMainViewModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct WeatherDetailsViewModelData {
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
        if let cityName = weatherResult?.cityName {
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

class WeatherDetailsViewModel {
    var weatherRepo:WeatherRepository
    
    var data:Dynamic<WeatherDetailsViewModelData>
    
    init(weatherRepo: WeatherRepository) {
        self.weatherRepo = weatherRepo
        
        data = Dynamic(WeatherDetailsViewModelData())
    }
}

// MARK: current weather fetching

extension WeatherDetailsViewModel {
    func fetchDefaultWeather() {
        do {
            if let searchHistory = try weatherRepo.getLatestHistory() {
                self.fetchCurrentWeather(cityId: searchHistory.cityId);
            }
        } catch {
            print("WeatherDetailsViewModel - fetchDefaultWeather - error")
            print(error)
        }
    }
    
    func fetchCurrentWeather(cityId: Int) {
        print("WeatherDetailsViewModel - fetchCurrentWeather - start")
        
        self.data.value.update(isLoading: true, errorMessage: "")
        
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            self.weatherRepo.findWeather(cityId: cityId, success: self.successHandler(), failure: self.failureHandler())
        }
    }
    
    func fetchCurrentWeather(cityName: String) {
        print("WeatherDetailsViewModel - fetchCurrentWeather - start")
        
        self.data.value.update(isLoading: true, errorMessage: "")
        
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            self.weatherRepo.findWeather(cityName: cityName, success: self.successHandler(), failure: self.failureHandler())
        }
    }
    
    private func successHandler() -> (OWWeatherResult) -> Void {
        return { [weak self] weatherResult in
            guard let strongSelf = self else { return }
            
            strongSelf.data.value.update(weatherResult: weatherResult, isLoading: false)
            strongSelf.insertSearchHistory(weatherResult: weatherResult)
        }
    }
    
    private func failureHandler() -> (OpenWeatherError, OWErrorResult?) -> Void {
        return { [weak self] error, errorResult in
            guard let strongSelf = self else { return }
        
            var errorMessage:String;

            switch error {
            case .knownError:
                if errorResult != nil {
                    errorMessage = errorResult!.message
                } else {
                    errorMessage = "Unknown error"
                }
                
                break
            case .decodingError:
                errorMessage = "Decode error"
                break
            default:
                errorMessage = "Unknown error"
                break
            }

            strongSelf.data.value.update(isLoading: false, errorMessage: errorMessage)
        }
    }
}

// MARK: search history handling

extension WeatherDetailsViewModel {
    private func insertSearchHistory(weatherResult: OWWeatherResult) {
        let searchHistory = SearchHistory(cityId: weatherResult.id, cityName: weatherResult.cityName, timestamp: Date().currentTimestamp())
        
        do {
            _ = try self.weatherRepo.deleteHisoryByCityId(searchHistory.cityId)
            _ = try self.weatherRepo.insertHistory(searchHistory)
        } catch {
            print("WeatherDetailsViewModel - insertSearchHistory - error")
            print(error)
        }
    }
}
