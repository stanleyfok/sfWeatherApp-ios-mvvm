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
}

// MARK: Search history repository related

extension SearchHistoryViewModel {
    func fetchAllSearchHistories() {
        do {
            let searchHistories = try self.searchHistoryRepo.findAll()
            
            self.data.value = {
                var cellViewModels = Array<SearchHistoryTableViewCellViewModel>()
                
                for searchHistory in searchHistories {
                    let cellViewModel = SearchHistoryTableViewCellViewModel(searchHistory: searchHistory)
                    
                    cellViewModels.append(cellViewModel)
                }
                
                return SearchHistoryViewModelData(cellViewModels: cellViewModels)
            }()
        } catch {
            print("HistoryViewModel - fetchAllSearchHistory - error")
            print(error);
        }
    }

    func removeSearchHistory(cityId: Int) {
        do {
            if let deletedRows = try self.searchHistoryRepo.deleteByCityId(cityId) {
                if (deletedRows >= 1) {
                    let filteredCellViewModels = self.data.value.cellViewModels.filter({ $0.getCityId() != cityId})
                    self.data.value = SearchHistoryViewModelData(cellViewModels: filteredCellViewModels)
                }
            }
            
        } catch {
            print("HistoryViewModel - removeSearchHistory - error")
            print(error);
        }
    }
}
