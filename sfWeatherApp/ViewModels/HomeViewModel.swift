//
//  WeatherMainViewModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct HomeViewModelData {
    var cityNameText:String
    var weatherText:String
    var temperatureText:String
    var errorMessage:String
    var isLoading:Bool
}

class HomeViewModel {
    var owService:OWService
    
    var data:Dynamic<HomeViewModelData>
    
    var lastCityName:String?
    
    init(owService: OWService) {
        self.owService = owService
        
        data = Dynamic(HomeViewModelData(
            cityNameText: "",
            weatherText: "",
            temperatureText: "",
            errorMessage: "",
            isLoading: false
        ))
    }
    
    public func fetchDefaultWeather() {
        // TODO: load from DB
        data.value = {
            var tmp = data.value
            tmp.cityNameText = "--"
            tmp.weatherText = "--"
            tmp.temperatureText = self.getFormattedTemperatureText(temperature: nil)
            
            return tmp
        }()
    }
    
    public func fetchWeatherByCityName(_ cityName: String) {
        print("WeatherHomeViewModel - fetchWeather")
        
        lastCityName = cityName
        
        data.value = {
            var tmp = data.value
            tmp.isLoading = true
            tmp.errorMessage = ""
            
            return tmp
        }()
        
        // to do error handling
        owService.fetchWeatherByCityName(cityName, success: {  [weak self] weatherResult in
            guard let strongSelf = self else { return }

            print("WeatherHomeViewModel - fetchWeather - success")
            
            strongSelf.data.value = {
                var tmp = strongSelf.data.value
                tmp.cityNameText = weatherResult.name
                tmp.weatherText = weatherResult.weather[0].main
                tmp.temperatureText = strongSelf.getFormattedTemperatureText(temperature: weatherResult.main.temp)
                tmp.isLoading = false
                
                return tmp
            }()
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
            
            strongSelf.data.value = {
                var tmp = strongSelf.data.value
                tmp.errorMessage = errorMessage
                tmp.isLoading = false
                
                return tmp
            }()
        })
    }
    
    private func getFormattedTemperatureText(temperature: Float?) -> String {
        if (temperature == nil) {
            return "--℃";
        }
        
        let mTemp = (temperature! - 273.15);
        
        //TODO: if decimal is 0, remove the decimal
        // e.g. 30.0℃ -> 30℃
        
        return "\(String(format: "%.1f", mTemp))℃";
    }
}
