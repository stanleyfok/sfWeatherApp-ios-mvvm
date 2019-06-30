//
//  HistoryViewModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct HistoryViewModelData {
    var searchHistories:Array<SearchHistory>
}

class HistoryViewModel {
    var searchHistoryRepo:SearchHistoryRepository
    var data:Dynamic<HistoryViewModelData>

    init(searchHistoryRepo:SearchHistoryRepository) {
        self.data = Dynamic(HistoryViewModelData(searchHistories: Array()))
        self.searchHistoryRepo = searchHistoryRepo
    }
    
    func fetchAllSearchHistories() {
        do {
            self.data.value.searchHistories = try self.searchHistoryRepo.findAll()
            
        } catch {
            print("HistoryViewModel - fetchAllSearchHistory - error")
            print(error);
        }
    }
}
