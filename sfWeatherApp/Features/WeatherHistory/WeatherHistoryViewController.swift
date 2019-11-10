//
//  HistoryViewController.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import UIKit

class WeatherHistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editNavButton: UIBarButtonItem!
 
    let weatherRepo:WeatherRepository = WeatherRepository()
    lazy var weatherHistoryViewModel:WeatherHistoryViewModel = {
        return WeatherHistoryViewModel(weatherRepo: weatherRepo)
    }()
    
    weak var weatherDetailsViewControllerDelegate: WeatherDetailsViewControllerSelectHistoryDelegate?
 
    override func viewDidLoad() {
        super .viewDidLoad()
        
        setupViews()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.weatherHistoryViewModel.fetchAllSearchHistories();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupBinding() {
        weatherHistoryViewModel.cellViewModels.bind { cellData in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: BarButtonItem

extension WeatherHistoryViewController {
    @IBAction func onEditBarButtonTapped(_ sender: Any) {
        if (self.tableView.isEditing == true) {
            tableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
    }
}

// MARK: TableView methods

extension WeatherHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellViewModels = weatherHistoryViewModel.cellViewModels.value
        return cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = weatherHistoryViewModel.cellViewModels.value[indexPath.row];
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherHistoryCell") ??
            UITableViewCell(style: .subtitle, reuseIdentifier: "WeatherHistoryCell")
                
        cell.textLabel?.text = cellViewModel.getCityName()
        cell.detailTextLabel?.text = cellViewModel.getSearchDate()
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = weatherHistoryViewModel.cellViewModels.value[indexPath.row];

        if let delegate = self.weatherDetailsViewControllerDelegate {
            delegate.onSelectWeatherHistory(cellViewModel.getCityId())
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let cellViewModel = weatherHistoryViewModel.cellViewModels.value[indexPath.row];

        if editingStyle == .delete {
            self.weatherHistoryViewModel.removeSearchHistory(cityId: cellViewModel.getCityId())
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
