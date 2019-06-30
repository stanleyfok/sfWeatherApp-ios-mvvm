//
//  HistoryViewController.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import UIKit

class SearchHistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var historyViewModel:SearchHistoryViewModel?
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

extension SearchHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cellViewModel = historyViewModel?.data.value.cellViewModels {
            return cellViewModel.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = (historyViewModel?.data.value.cellViewModels[indexPath.row])!;
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SearchHistoryCell")
        }
        
        cell?.textLabel?.text = cellViewModel.cityName
        cell?.detailTextLabel?.text = cellViewModel.getFormattedSearchDate()
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = (historyViewModel?.data.value.cellViewModels[indexPath.row])!;

        self.homeViewControllerDelegate?.onSelectSearchHistory(cellViewModel)
    }
}
