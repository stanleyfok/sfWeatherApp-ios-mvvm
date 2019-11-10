//
//  ViewController.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import UIKit

protocol WeatherDetailsViewControllerSelectHistoryDelegate: class {
    func onSelectWeatherHistory(_ cityId: Int)
}

class WeatherDetailsViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewHistoryButton: UIButton!
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self

        return searchController;
    }()
    
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
                destinationVC.weatherDetailsViewControllerDelegate = self
            }
        }
    }
    
    private func setupViews() {
        self.hideKeyboardWhenTappedAround()
        
        navigationItem.searchController = searchController
    }
    
    private func setupBinding() {
        weatherDetailsViewModel.weatherResult.bindAndFire { weatherResult in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.cityNameLabel.text = strongSelf.weatherDetailsViewModel.getCityNameText()
                strongSelf.weatherLabel.text = strongSelf.weatherDetailsViewModel.getWeatherText()
                strongSelf.temperatureLabel.text = strongSelf.weatherDetailsViewModel.getTemperatureText()
            }
        }
        
        weatherDetailsViewModel.isLoading.bind { isLoading in
            DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
                
                if (isLoading) {
                    strongSelf.activityIndicator.startAnimating()
                } else {
                    strongSelf.activityIndicator.stopAnimating()
                }
            }
        }
        
        weatherDetailsViewModel.errorMessage.bind { errorMessage in
            DispatchQueue.main.async {[weak self] in
                guard let strongSelf = self else { return }
                    
                if (errorMessage != nil) {
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    
                    strongSelf.present(alert, animated: true)
                }
            }
        }
    }
}

extension WeatherDetailsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.weatherDetailsViewModel.fetchCurrentWeather(cityName: searchBar.text!)
        
        searchBar.endEditing(true)
        
        searchController.isActive = false
    }
}

extension WeatherDetailsViewController: WeatherDetailsViewControllerSelectHistoryDelegate {
    func onSelectWeatherHistory(_ cityId: Int) {
        self.navigationController?.popViewController(animated: true)
        
        self.weatherDetailsViewModel.fetchCurrentWeather(cityId: cityId)
    }
}
