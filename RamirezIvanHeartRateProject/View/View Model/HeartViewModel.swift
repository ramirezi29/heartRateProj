//
//  HeartViewModel.swift
//  RamirezIvanHeartRateProject
//
//  Created by Ivan Ramirez on 4/12/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import Foundation
import HealthKit

class HeartViewModel {
    
    static let sharedInstance = HeartViewModel()
    let healthStore = HKHealthStore()
    var heartRates: [HeartRate] = []
    
    init() { loadPersistentStorage() }
    
    // MARK: - Fetch HR Records
    
    func fetchHealthStoreHeartRates(completion: @escaping (Result<[HKSample], Error>) -> Void) {
        let startDate = Date.distantPast
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate as Date, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        guard let heartRateSample = HealthController.sharedInstance.heartRate else {
            return
        }
        
        let heartRateQuery =  HKSampleQuery(sampleType: heartRateSample, predicate: predicate, limit: 100, sortDescriptors: [sortDescriptor]) { (query, hrSamples, error) in
            //Perform Query
            if let error = error {
                print("There was an error with obtaining the heart rate samples due to \(error); \(error.localizedDescription)")
                completion(.failure(HealthKitResult.error))
                return
            }
            guard let hrSamples = hrSamples else {
                completion(.failure(HealthKitResult.dataNotAvailable))
                return
            }
            
            var samplesFetched: [HeartRate] = []
            
            for records in hrSamples {
                
                guard let healthData: HKQuantitySample = records as? HKQuantitySample else {
                    completion(.failure(HealthKitResult.error))
                    return
                }
                
                let hrBPM = Int(healthData.quantity.doubleValue(for: HealthController.sharedInstance.heartRateUnit))
                let startDate = healthData.startDate
                let endDate = healthData.endDate
                let uuid = healthData.uuid.description
                let hearRateInfoFetched = HeartRate(hrBPM: hrBPM, startDate: startDate, endDate: endDate, heartRateUUID: uuid)
                samplesFetched.append(hearRateInfoFetched)
            }
            
            self.heartRates = samplesFetched
            
            completion(.success(hrSamples))
        }
        DispatchQueue.main.async {
            self.healthStore.execute(heartRateQuery)
        }
    }
    
    // MARK: - Create Heart Rate Record
    
    func createHearRateWith(hrBPM: Double, startDate: Date, endDate: Date, completion: @escaping (Result<HKQuantitySample, Error>) -> Void) {
        
        //TODO - append this to the source of truth
        let heartRate = HeartRate(hrBPM: Int(hrBPM), startDate: startDate, endDate: endDate)
        
        guard let type = HealthController.sharedInstance.heartRate else {
            completion(.failure(HealthKitResult.error))
            return  }
        
        let hkQuantity = HKQuantity(unit: HealthController.sharedInstance.heartRateUnit, doubleValue: hrBPM)
        let newHeartRate = HKQuantitySample(type: type, quantity: hkQuantity, start: startDate, end: endDate)
        
        healthStore.save(newHeartRate) { (success, error) in
            if let error = error {
                print("There was an error with saving the new hear rate to the store due to: \(error); \(error.localizedDescription)")
            } else {
                self.heartRates.append(heartRate)
                self.saveToPersistentStorage()
                completion(.success(newHeartRate))
            }
        }
        
    }
    
    // MARK: - Delete Heart Rate Record
    
    func removeHearRate(heartRate: HeartRate, completion: @escaping(Result<[HKSample],Error>)-> Void ) {
        
        guard let indexPath = heartRates.firstIndex(of: heartRate) else {
            completion(.failure(HealthKitResult.error))
            return
        }
        
        let startDate = heartRate.startDate
        let endDate = heartRate.endDate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate as Date, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        guard let heartRateSample = HealthController.sharedInstance.heartRate else {
            return
        }
        
        let hrChangeRequest = HKSampleQuery(sampleType: heartRateSample, predicate: predicate, limit: 100, sortDescriptors: [sortDescriptor]) { (_, hrSamples, error) in
            if let error = error {
                print("There was an error with obtaining the heart rate samples due to  \(error); \(error.localizedDescription)")
                completion(.failure(HealthKitResult.error))
                return
            }
            guard let hrSamples = hrSamples else {
                completion(.failure(HealthKitResult.dataNotAvailable))
                return
            }
            
            self.healthStore.delete(hrSamples) { (_, error) in
                if let error = error {
                    print("There was an error with deleting the item from the health store due to \(error);\n\(error.localizedDescription)")
                } else {
                    self.heartRates.remove(at: indexPath)
                    self.saveToPersistentStorage()
                    completion(.success(hrSamples))
                }
            }
        }
        self.healthStore.execute(hrChangeRequest)
        DispatchQueue.main.async {
        }
    }
    
    func filePath() -> URL {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let path = paths.first else { fatalError("Bad Path")}
        let url = path.appendingPathComponent("heartRate.json")
        return url
    }
    
    // NOTE: - Only heat rate records created inside this app wil be saved to sourche of truth
    func saveToPersistentStorage() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(heartRates)
            try data.write(to: filePath())
        } catch let error {
            print("There was an error due to \(error); \(error.localizedDescription)")
        }
    }
    
    func loadPersistentStorage(){
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: filePath())
            let heartRates = try decoder.decode([HeartRate].self, from: data)
            self.heartRates = heartRates
        } catch let error {
            print("There was an error loading from the persistenct storage \(error); \(error.localizedDescription)")
        }
    }
}
