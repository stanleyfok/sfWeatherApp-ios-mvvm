//
//  BaseSQLiteRepository.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation
import SQLite

class BaseSQLiteRepository {
    var db:Connection?
    
    func connect(dbName:String) throws {
        let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
        ).first!
        
        let fullDBPath = "\(path)/\(dbName)"
    
        print(fullDBPath)
        
        db = try Connection(fullDBPath)
    }
    
    func isTableExists(_ table: Table) -> Bool {
        do {
            _ = try db?.scalar(table.exists)
            
            return true
        } catch {
            return false
        }
    }
    
    func createTableIfNeeded(tableName: String, tableCreator: @escaping (TableBuilder) -> Void ) throws {
        let table = Table(tableName)
        
        if (!self.isTableExists(table)) {
            try db?.run(table.create { t in
                tableCreator(t)
            })
        }
    }
    
    func find(table: Table) throws -> AnySequence<Row>? {
        return try db?.prepare(table);
    }
    
    func insert(_ insert: Insert) throws -> Int64? {
        return try db?.run(insert)
    }
    
    func delete(table: Table) throws -> Int? {
        return try db?.run(table.delete())
    }
}
