//
//  SearchHistoryRepository.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation
import SQLite

class SearchHistoryDAO: BaseSQLiteDAO {
    private let dbName = "sfWeather.sqlite3"
    private let tableName = "searchHistories"
    
    // schema
    private let fCityId = Expression<Int>("cityId")
    private let fCityName = Expression<String>("cityName")
    private let fTimestamp = Expression<Int>("timestamp")
    
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
        t.column(fCityId, primaryKey: true)
        t.column(fCityName)
        t.column(fTimestamp)
    }
    
    func findAll() throws -> Array<SearchHistory> {
        let table = Table(tableName)
        var searchHistories:Array<SearchHistory> = Array()
        
        if let rows = try super.find(table: table.order(fTimestamp.desc)) {
            for row in rows {
                let searchHistory = SearchHistory(cityId: row[fCityId], cityName: row[fCityName], timestamp: row[fTimestamp])
                
                searchHistories.append(searchHistory)
            }
        }
        
        return searchHistories
    }
    
    func findLatest() throws -> SearchHistory? {
        let table = Table(tableName)
        
        if let row = try super.findOne(table: table.order(fTimestamp.desc)) {
            let searchHistory = SearchHistory(cityId: row[fCityId], cityName: row[fCityName], timestamp: row[fTimestamp])
        
            return searchHistory
        }
    
        return nil
    }
    
    func insert(_ searchHistory: SearchHistory) throws -> Int64? {
        let table = Table(tableName)
        
        let insertQuery = table.insert(fCityId <- searchHistory.cityId, fCityName <- searchHistory.cityName, fTimestamp <- searchHistory.timestamp)
        
        return try super.insert(insertQuery)
    }
    
    func deleteByCityId(_ cityId: Int) throws -> Int? {
        let table = Table(tableName)
        let filteredTable = table.filter(fCityId == cityId)
        
        return try super.delete(table: filteredTable)            
    }
}
