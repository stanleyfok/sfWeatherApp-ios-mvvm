//
//  WeatherModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//
// Ref: https://openweathermap.org/current

import Foundation

struct OWWeatherResult: Decodable {
    var id: Int
    var cityName: String
    var timezone: Int
    var base: String
    var visibility: Int?
    var dt: Int
    
    var coord: OWCoord
    var weather: [OWWeather]
    var main: OWMain
    var wind: OWWind
    var clouds: OWClouds
    var sys: OWSys
    
    enum CodingKeys: String, CodingKey {
        case id
        case cityName = "name" // rename
        case timezone
        case base
        case visibility
        case dt
        case coord
        case weather
        case main
        case wind
        case clouds
        case sys
    }
    
    struct OWCoord: Decodable {
        var lon: Float
        var lat: Float
    }
    
    struct OWWeather: Decodable {
        var id: Int
        var main: String
        var description: String
        var icon: String
    }
    
    struct OWMain: Decodable {
        var temp: Float
        var pressure: Float
        var humidity: Float
        var tempMin: Float
        var tempMax: Float
        
        enum CodingKeys: String, CodingKey {
            case temp
            case pressure
            case humidity
            case tempMin = "temp_min" // use cammal's rule
            case tempMax = "temp_max" // use cammal's rule
        }
    }
    
    struct OWWind: Decodable {
        var speed: Float
        var deg: Float?
    }
    
    struct OWClouds: Decodable {
        var all: Float
    }
    
    struct OWSys: Decodable {
        var type: Int
        var id: Int
        var country: String
        var sunrise: Int
        var sunset: Int
    }
}
