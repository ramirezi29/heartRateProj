//
//  HeartRateListTVC.swift
//  RamirezIvanHeartRateProject
//
//  Created by Ivan Ramirez on 4/13/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit

class HeartRateListTVC: UITableViewController {
    
    // MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData(_:)))
        
        fetchHRInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchHRInfo()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HeartViewModel.sharedInstance.heartRates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.heartRateCell, for: indexPath) as? HeartRateTVCell else {
            return UITableViewCell()
        }
        
        let heartRate = HeartViewModel.sharedInstance.heartRates[indexPath.row]
        cell.heartRate = heartRate
        
        return cell
    }
    
    // MARK: -  Delete
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let hearRateRecord = HeartViewModel.sharedInstance.heartRates[indexPath.row]
            
            HeartViewModel.sharedInstance.removeHearRate(heartRate: hearRateRecord) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                case .failure(_):
                    let deleteErrorNotif = AlertController.presentAlertControllerWith(alertTitle: "Error Deleting Record", alertMessage: "Ensure you are signed into to your iCloud and Health account and try again", dismissActionTitle: "Ok")
                    DispatchQueue.main.async {
                        self.present(deleteErrorNotif, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    @objc func refreshData(_ sender: Any) {
        fetchHRInfo()
    }
}

// MARK: - Fetch 

extension HeartRateListTVC {
    func fetchHRInfo() {
        
        HeartViewModel.sharedInstance.fetchHealthStoreHeartRates{ (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(_):
                print(HealthKitResult.error.localizedDescription)
                let errorFetchingHRAlert =     AlertController.presentAlertControllerWith(alertTitle: "Error Obtaining Results", alertMessage: "Please ensure you are synch with your Apple Healt app and try again", dismissActionTitle: "Ok")
                DispatchQueue.main.async {
                    self.present(errorFetchingHRAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
