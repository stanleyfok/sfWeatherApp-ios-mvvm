//
//  HistoryTableCellViewModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 7/1/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct SearchHistoryTableViewCellViewModel {
    var cityId: Int
    var cityName: String
    var timestamp: Int
    
    func getFormattedSearchDate() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self.timestamp))
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)

        return "Last search on: \(strDate)";
    }
}
