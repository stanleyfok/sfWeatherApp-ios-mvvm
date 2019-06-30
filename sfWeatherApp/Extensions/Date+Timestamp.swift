//
//  Date+Timestamp.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

extension Date {
    func currentTimestamp() -> Int {
        return Int(self.timeIntervalSince1970)
    }
}
