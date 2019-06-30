//
//  HistoryViewController.swift
//  sfWeatherApp
//
//  Created by Fok, Stanley on 6/30/19.
//  Copyright © 2019 Stanley Fok. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!

    var numberToShow:Int = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.textLabel.text = "\(numberToShow)"
    }
}
