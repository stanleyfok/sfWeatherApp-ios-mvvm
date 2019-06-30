//
//  WeatherModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//
// Ref: https://openweathermap.org/current

import Foundation

struct OWErrorResult: Codable {
    var code:String
    var message:String
    
    enum CodingKeys: String, CodingKey {
        case code = "cod" // rename
        case message = "message"
    }
}

struct OWWeatherResult: Codable {
    var id: Int
    var name: String
    var timezone: Int
    var base: String
    var visibility: Int
    var dt: Int32
    
    var coord: OWCoord
    var weather: [OWWeather]
    var main: OWMain
    var wind: OWWind
    var clouds: OWClouds
    var sys: OWSys
    
    struct OWCoord: Codable {
        var lon: Float
        var lat: Float
    }
    
    struct OWWeather: Codable {
        var id: Int
        var main: String
        var description: String
        var icon: String
    }
    
    struct OWMain: Codable {
        var temp: Float
        var pressure: Float
        var humidity: Float
        var tempMin: Float
        var tempMax: Float
        
        enum CodingKeys: String, CodingKey {
            case temp = "temp"
            case pressure = "pressure"
            case humidity = "humidity"
            case tempMin = "temp_min" // use cammal's rule
            case tempMax = "temp_max" // use cammal's rule
        }
    }
    
    struct OWWind: Codable {
        var speed: Float
        var deg: Float
    }
    
    struct OWClouds: Codable {
        var all: Float
    }
    
    struct OWSys: Codable {
        var type: Int
        var id: Int
        var message: Float
        var country: String
        var sunrise: Int32
        var sunset: Int32
    }
}
