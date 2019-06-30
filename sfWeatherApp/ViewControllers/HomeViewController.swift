//
//  ViewController.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import UIKit

protocol HomeViewControllerSelectHistoryDelegate {
    func onSelectSearchHistory(_ viewModel: SearchHistoryTableViewCellViewModel)
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewHistoryButton: UIButton!
    
    var searchController: UISearchController?
    
    let owService:OWService = OWService()
    let searchHistoryRepo:SearchHistoryRepository = SearchHistoryRepository()

    lazy var homeViewModel:HomeViewModel = {
        return HomeViewModel(owService: owService, searchHistoryRepo: searchHistoryRepo)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupBinding()
        
        homeViewModel.fetchDefaultWeather()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowHistorySegue" {
            if let destinationVC = segue.destination as? SearchHistoryViewController {
                destinationVC.historyViewModel = SearchHistoryViewModel(searchHistoryRepo: searchHistoryRepo)
                destinationVC.homeViewControllerDelegate = self
            }
        }
    }
    
    private func setupViews() {
        self.hideKeyboardWhenTappedAround()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    private func setupBinding() {
        homeViewModel.data.bind { data in
            DispatchQueue.main.async {
                self.cityNameLabel.text = data.cityName
                self.weatherLabel.text = data.weather
                self.temperatureLabel.text = data.getFormattedTemperatureText()
                
                if (data.isLoading) {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
                
                if (data.errorMessage != "") {
                    let alert = UIAlertController(title: "Error", message: data.errorMessage, preferredStyle: .alert)
                    //alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                        // TODO
                        //self.homeViewModel.fetchWeatherByCityName(self.homeViewModel.lastCityName!)
                    //  }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let fetchType:OWFetchCurrentWeatherType = .byCityName(cityName: searchBar.text!)
        self.homeViewModel.fetchCurrentWeather(fetchType)
        
        searchBar.endEditing(true)
        
        searchController?.isActive = false
    }
}

extension HomeViewController: HomeViewControllerSelectHistoryDelegate {
    func onSelectSearchHistory(_ cellViewModel: SearchHistoryTableViewCellViewModel) {
        self.navigationController?.popViewController(animated: true)
        
        let fetchType:OWFetchCurrentWeatherType = .byCityId(cityId: cellViewModel.cityId)
        self.homeViewModel.fetchCurrentWeather(fetchType)
    }
}
