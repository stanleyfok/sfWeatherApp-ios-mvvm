//
//  WeatherMainViewModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

class WeatherDetailsViewModel {
    var weatherRepo:WeatherRepository
    var weatherResult:Dynamic<OWWeatherResult?> = Dynamic(nil)
    var errorMessage:Dynamic<String?> = Dynamic(nil)
    var isLoading:Dynamic<Bool> = Dynamic(false)
    
    init(weatherRepo: WeatherRepository) {
        self.weatherRepo = weatherRepo       
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
        
        self.isLoading.value = true
        self.errorMessage.value = nil
        
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            self.weatherRepo.findWeather(by: cityId, success: self.successHandler(), failure: self.failureHandler())
        }
    }
    
    func fetchCurrentWeather(cityName: String) {
        print("WeatherDetailsViewModel - fetchCurrentWeather - start")
        
        self.isLoading.value = true
        self.errorMessage.value = nil
        
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            self.weatherRepo.findWeather(by: cityName, success: self.successHandler(), failure: self.failureHandler())
        }
    }
    
    private func successHandler() -> (OWWeatherResult) -> Void {
        return { [weak self] weatherResult in
            guard let strongSelf = self else { return }
            
            strongSelf.weatherResult.value = weatherResult
            strongSelf.isLoading.value = false
            
            strongSelf.insertSearchHistory(weatherResult: weatherResult)
        }
    }
    
    private func failureHandler() -> (OWError, OWErrorResult?) -> Void {
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

            strongSelf.isLoading.value = false
            strongSelf.errorMessage.value = errorMessage
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

// MARK: obtaining data from model

extension WeatherDetailsViewModel {
    func getCityNameText() -> String {
        if let cityName = self.weatherResult.value?.cityName {
            return cityName
        }
        
        return "--"
    }

    func getWeatherText() -> String {
        if let weather = self.weatherResult.value?.weather[0].main  {
            return weather
        }
        
        return "--"
    }

    func getTemperatureText() -> String {
        if let temperature = self.weatherResult.value?.main.temp {
            if (temperature.isNaN) {
                return "--°"
            }

            let mTemp = (temperature - 273.15);

            return "\(String(format: "%.1f", mTemp))°";
        }
        
        return "--°"
    }
}
