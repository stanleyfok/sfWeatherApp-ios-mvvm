//
//  HistoryViewModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct SearchHistoryViewModelData {
    var cellViewModels:Array<SearchHistoryTableViewCellViewModel>
}

struct SearchHistoryViewModel {
    var searchHistoryRepo:SearchHistoryRepository
    var data:Dynamic<SearchHistoryViewModelData>

    init(searchHistoryRepo:SearchHistoryRepository) {
        self.data = Dynamic(SearchHistoryViewModelData(cellViewModels: Array<SearchHistoryTableViewCellViewModel>()))
        self.searchHistoryRepo = searchHistoryRepo
    }
    
    func fetchAllSearchHistories() {
        do {
            let searchHistories:Array<SearchHistory> = try self.searchHistoryRepo.findAll()
            
            self.data.value = {
                var cellViewModels = Array<SearchHistoryTableViewCellViewModel>()
                
                for searchHistory in searchHistories {
                    let cellViewModel = SearchHistoryTableViewCellViewModel(cityId: searchHistory.cityId, cityName: searchHistory.cityName, timestamp: searchHistory.timestamp)
                    
                    cellViewModels.append(cellViewModel)
                }
                
                return SearchHistoryViewModelData(cellViewModels: cellViewModels)
            }()
        } catch {
            print("HistoryViewModel - fetchAllSearchHistory - error")
            print(error);
        }
    }
}
