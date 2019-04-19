//
//  OnboardingVC.swift
//  RamirezIvanHeartRateProject
//
//  Created by Ivan Ramirez on 4/13/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit
import HealthKit

class OnboardingVC: UIViewController {
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var authorizeHKButton: IRButton!
    
    var authroizeButtonTapped = false
    var disableOnBarding = false
    var disableOnboardingKey = "disableOnboardingKey"
    
    // MARK: - Life Cyles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserDefaults()
        instructionLabel.text = "Click on the button below to allow Heart Rate Tracker to access your Health information"
        authorizeHKButton.setTitle("Authorize Access", for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.isOnboardedKey)
    }
    
    //Only show the user the onboarding screen if the disableOnBarding is set to false
    func loadUserDefaults(){
        disableOnBarding = UserDefaults.standard.bool(forKey: disableOnboardingKey)
    }
    
    //The root view controller gets switched to the Heart Rate Table View Controller 
    func presentMainView() {
        let HomeStoryboard = UIStoryboard(name: Constants.storyBoardConstants.homeScreenStoryBoard, bundle: nil).instantiateInitialViewController()!
        UIApplication.shared.keyWindow?.rootViewController = HomeStoryboard
        present(HomeStoryboard, animated: true, completion: nil)
    }
    
    @IBAction func authorizeButtonTapped(_ sender: IRButton) {
        switch authroizeButtonTapped {
        case false:
            HealthController.authorizeHK { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.authorizeHKButton.backgroundColor = ColorController.green.value
                        self.authorizeHKButton.setTitle("Lets Get Started", for: .normal)
                        self.instructionLabel.text = "Click on the button below"
                        self.authroizeButtonTapped = true
                    }
                case .failure(_):
                    let onboardingErrorNotif = AlertController.presentAlertControllerWith(alertTitle: "Error", alertMessage: "An issue occurred while attempting to grant permission, please try again", dismissActionTitle: "OK")
                    DispatchQueue.main.async {
                        self.present(onboardingErrorNotif, animated: true, completion: nil)
                    }
                    print(HealthKitResult.error)
                }
            }
        case true:
            UserDefaults.standard.set(true, forKey: Constants.UserDefaults.isOnboardedKey)
            presentMainView()
        }
    }
}
