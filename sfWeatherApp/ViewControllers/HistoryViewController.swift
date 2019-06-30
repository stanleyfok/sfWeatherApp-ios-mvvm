//
//  HistoryViewController.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var historyViewModel:HistoryViewModel?
    var homeViewControllerDelegate: HomeViewControllerSelectHistoryDelegate?
 
    override func viewDidLoad() {
        super .viewDidLoad()
        
        setupViews()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.historyViewModel?.fetchAllSearchHistories();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchHistoryCell")
    }
    
    private func setupBinding() {
        historyViewModel?.data.bind { data in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchHistories = historyViewModel?.data.value.searchHistories {
            return searchHistories.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchHistory = (historyViewModel?.data.value.searchHistories[indexPath.row])!;
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "SearchHistoryCell")
        }
        
        cell?.textLabel?.text = searchHistory.citName
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchHistory = (historyViewModel?.data.value.searchHistories[indexPath.row])!;

        self.homeViewControllerDelegate?.onSelectSearchHistory(searchHistory)
    }
}
