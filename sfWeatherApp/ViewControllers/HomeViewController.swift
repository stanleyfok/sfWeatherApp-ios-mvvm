//
//  ViewController.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/29/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewHistoryButton: UIButton!
    
    var searchController: UISearchController?
    
    let owService:OWService = OWService()

    lazy var homeViewModel:HomeViewModel = {
        return HomeViewModel(owService: owService)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        setupBinding()
        
        homeViewModel.fetchDefaultWeather()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowHistorySegue" {
            if let destinationVC = segue.destination as? HistoryViewController {
                // data passing here
                destinationVC.numberToShow = 100
            }
        }
    }
    
    private func setupViews() {
        self.hideKeyboardWhenTappedAround()
        
        //self.searchBar.delegate = self
        
        self.viewHistoryButton.addTarget(
            self,
            action: #selector(self.viewHistoryButtonTapped),
            for: .touchUpInside)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    func singleTap(sender: UITapGestureRecognizer) {
        self.searchBar.endEditing(true)
    }
    
    private func setupBinding() {
        
        homeViewModel.data.bind { data in
            DispatchQueue.main.async {
                self.cityNameLabel.text = data.cityNameText
                self.weatherLabel.text = data.weatherText
                self.temperatureLabel.text = data.temperatureText
                
                if (data.isLoading) {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
                
                if (data.errorMessage != "") {
                    let alert = UIAlertController(title: "Error", message: data.errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                        self.homeViewModel.fetchWeatherByCityName(self.homeViewModel.lastCityName!)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.homeViewModel.fetchWeatherByCityName(searchBar.text!)
        
        searchBar.endEditing(true)
        
        searchController?.isActive = false
    }
}

extension HomeViewController {
    @objc func viewHistoryButtonTapped() {
        
    }
}
