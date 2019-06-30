//
//  SearchHistoryRepository.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation
import SQLite

class SearchHistoryRepository: BaseSQLiteRepository {
    private let dbName = "sfWeather.sqlite3"
    private let tableName = "searchHistories"
    
    // schema
    private let cityId = Expression<Int>("cityId")
    private let cityName = Expression<String>("cityName")
    private let timestamp = Expression<Int>("timestamp")
    
    override init() {
        super.init()

        do {
            try self.connect(dbName: dbName)
            try self.createTableIfNeeded(tableName: tableName, tableCreator: tableCreator)
        } catch {
            print(error)
        }
    }
    
    private func tableCreator(_ t: TableBuilder) {
        t.column(cityId, primaryKey: true)
        t.column(cityName)
        t.column(timestamp)
    }
    
    func findAll() throws -> Array<SearchHistory> {
        let table = Table(tableName)
        var searchHistories:Array<SearchHistory> = Array()
        
        if let rows = try super.find(table: table.order(timestamp.desc)) {
            for row in rows {
                let searchHistory = SearchHistory(cityId: row[cityId], cityName: row[cityName], timestamp: row[timestamp])
                
                searchHistories.append(searchHistory)
            }
        }
        
        return searchHistories
    }
    
    func findLatest() throws -> SearchHistory? {
        let table = Table(tableName)
        
        if let row = try super.findOne(table: table.order(timestamp.desc)) {
            let searchHistory = SearchHistory(cityId: row[cityId], cityName: row[cityName], timestamp: row[timestamp])
        
            return searchHistory
        }
    
        return nil
    }
    
    func insert(_ searchHistory: SearchHistory) throws -> Int64? {
        let table = Table(tableName)
        
        let insertQuery = table.insert(cityId <- searchHistory.cityId, cityName <- searchHistory.cityName, timestamp <- searchHistory.timestamp)
        
        return try super.insert(insertQuery)
    }
    
    func delete(_ searchHistory: SearchHistory) throws -> Int? {
        let table = Table(tableName)
        let filteredTable = table.filter(cityId == searchHistory.cityId)
        
        return try super.delete(table: filteredTable)            
    }
}
