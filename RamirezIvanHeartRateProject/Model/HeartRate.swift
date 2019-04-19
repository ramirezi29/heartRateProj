//
//  HeartRate.swift
//  RamirezIvanHeartRateProject
//
//  Created by Ivan Ramirez on 4/13/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import Foundation

//Conformed to Equatable in order to correctly delete the specified heart rate record 
class HeartRate: Codable, Equatable {
    static func == (lhs: HeartRate, rhs: HeartRate) -> Bool {
        if rhs.heartRateUUID != lhs.heartRateUUID {return false}
        if rhs.hrBPM != lhs.hrBPM {return false}
        return true 
    }
    
    var hrBPM: Int
    var heartRateUUID: String
    var startDate: Date
    var endDate: Date
    
    init(hrBPM: Int, startDate: Date, endDate: Date, heartRateUUID: String = UUID().uuidString) {
        self.hrBPM = hrBPM
        self.startDate = startDate
        self.endDate = endDate
        self.heartRateUUID = heartRateUUID
    }
    
    var startDateAsString: String {
        return DateFormatter.localizedString(from: startDate, dateStyle: .short, timeStyle: .short)
    }
    
    var endDateAsString: String {
        return DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .short)
    }
}

