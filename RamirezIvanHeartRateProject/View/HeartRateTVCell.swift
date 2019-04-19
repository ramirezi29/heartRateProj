//
//  HeartRateTVCell.swift
//  RamirezIvanHeartRateProject
//
//  Created by Ivan Ramirez on 4/13/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit

class HeartRateTVCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var heartRateValue: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    var heartRate: HeartRate? {
        didSet {
            layoutIfNeeded()
            updateViews()
        }
    }
    
    func updateViews() {
        guard let heartRate = heartRate else {
            return
        }
        dateLabel.text = "Start: \(heartRate.startDateAsString)"
        endDateLabel.text = "End:\(heartRate.endDateAsString)"
        heartRateValue.text = "\(heartRate.hrBPM)"
    }
}
