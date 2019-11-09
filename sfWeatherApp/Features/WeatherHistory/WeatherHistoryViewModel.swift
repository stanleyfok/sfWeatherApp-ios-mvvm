//
//  HistoryViewModel.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import Foundation

struct WeatherHistoryViewModelData {
    var cellViewModels:Array<WeatherHistoryTableViewCellViewModel>
}

struct WeatherHistoryViewModel {
    var weatherRepo:WeatherRepository
    var data:Dynamic<WeatherHistoryViewModelData>

    init(weatherRepo:WeatherRepository) {
        self.weatherRepo = weatherRepo
        self.data = Dynamic(WeatherHistoryViewModelData(cellViewModels: Array<WeatherHistoryTableViewCellViewModel>()))
    }
}

// MARK: Search history repository related

extension WeatherHistoryViewModel {
    func fetchAllSearchHistories() {
        do {
            let searchHistories = try self.weatherRepo.getAllHistories()
            
            self.data.value = {
                var cellViewModels = Array<WeatherHistoryTableViewCellViewModel>()
                
                for searchHistory in searchHistories {
                    let cellViewModel = WeatherHistoryTableViewCellViewModel(searchHistory: searchHistory)
                    
                    cellViewModels.append(cellViewModel)
                }
                
                return WeatherHistoryViewModelData(cellViewModels: cellViewModels)
            }()
        } catch {
            print("WeatherHistoryViewModel - fetchAllSearchHistory - error")
            print(error);
        }
    }

    func removeSearchHistory(cityId: Int) {
        do {
            if let deletedRows = try self.weatherRepo.deleteHisoryByCityId(cityId) {
                if (deletedRows >= 1) {
                    let filteredCellViewModels = self.data.value.cellViewModels.filter({ $0.getCityId() != cityId})
                    self.data.value = WeatherHistoryViewModelData(cellViewModels: filteredCellViewModels)
                }
            }
            
        } catch {
            print("WeatherHistoryViewModel - removeSearchHistory - error")
            print(error);
        }
    }
}
