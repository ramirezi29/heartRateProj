//
//  HealthController.swift
//  RamirezIvanHeartRateProject
//
//  Created by Ivan Ramirez on 4/13/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import HealthKit

class HealthController {
    
    static let sharedInstance = HealthController()
    
    let heartRateUnit = HKUnit(from: "count/min")
    
    let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)
    
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    static func authorizeHK(completion: @escaping (Result<Bool, Error>) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else { completion(.failure(HealthKitResult.notSupportOnDevice))
            return
        }
        
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) else { completion(.failure(HealthKitResult.dataNotAvailable))
            return
        }
        
        let heartRateToWrite: Set<HKSampleType> = [heartRate]
        let heartRateToRead: Set<HKObjectType> = [heartRate]
        
        HKHealthStore().requestAuthorization(toShare: heartRateToWrite, read: heartRateToRead) { (success, _) in
            completion(.success(success))
        }
    }
}
