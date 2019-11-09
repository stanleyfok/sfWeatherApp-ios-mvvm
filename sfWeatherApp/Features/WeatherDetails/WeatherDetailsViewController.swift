//
//  ViewController.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import UIKit

protocol WeatherDetailsViewControllerSelectHistoryDelegate {
    func onSelectWeatherHistory(_ cityId: Int)
}

class WeatherDetailsViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewHistoryButton: UIButton!
    
    var searchController: UISearchController?
    
    let weatherRepo:WeatherRepository = WeatherRepository()

    lazy var weatherDetailsViewModel:WeatherDetailsViewModel = {
        return WeatherDetailsViewModel(weatherRepo: weatherRepo)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupBinding()
        
        weatherDetailsViewModel.fetchDefaultWeather()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowHistorySegue" {
            if let destinationVC = segue.destination as? WeatherHistoryViewController {
                destinationVC.weatherHistoryViewModel = WeatherHistoryViewModel(weatherRepo: weatherRepo)
                destinationVC.weatherDetailsViewControllerDelegate = self
            }
        }
    }
    
    private func setupViews() {
        self.hideKeyboardWhenTappedAround()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    private func setupBinding() {
        weatherDetailsViewModel.data.bindAndFire { data in
            DispatchQueue.main.async {
                self.cityNameLabel.text = data.getCityNameText()
                self.weatherLabel.text = data.getWeatherText()
                self.temperatureLabel.text = data.getTemperatureText()
                
                if (data.isLoading) {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
                
                if (data.errorMessage != "") {
                    let alert = UIAlertController(title: "Error", message: data.errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension WeatherDetailsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.weatherDetailsViewModel.fetchCurrentWeather(cityName: searchBar.text!)
        
        searchBar.endEditing(true)
        
        searchController?.isActive = false
    }
}

extension WeatherDetailsViewController: WeatherDetailsViewControllerSelectHistoryDelegate {
    func onSelectWeatherHistory(_ cityId: Int) {
        self.navigationController?.popViewController(animated: true)
        
        self.weatherDetailsViewModel.fetchCurrentWeather(cityId: cityId)
    }
}
