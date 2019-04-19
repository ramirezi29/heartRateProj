//
//  HealthKitError.swift
//  RamirezIvanHeartRateProject
//
//  Created by Ivan Ramirez on 4/13/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import Foundation

enum HealthKitResult: Error {
    case success
    case notSupportOnDevice
    case dataNotAvailable
    case error
    
    var localizedDescription: String {
        switch self {
        case .success:
            return String()
        case .notSupportOnDevice:
            return "Device does not support this feature"
        case .dataNotAvailable:
            return "Requested data is not available"
        case .error:
            return "An error occured while attempting to complete the request"
        }
    }
}
