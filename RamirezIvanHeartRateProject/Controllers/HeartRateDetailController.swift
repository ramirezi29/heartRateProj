//
//  HeartRateDetailController.swift
//  RamirezIvanHeartRateProject
//
//  Created by Ivan Ramirez on 4/14/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit

class HeartRateDetailController: UIViewController {
    
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var bpmTextField: UITextField!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDateTextField: UITextField!
    
    var toolBar = UIToolbar()
    let hrDatePicker = UIDatePicker()
    
    // MARK: - Life Cyles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenTapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeys(_:)))
        
        view.addGestureRecognizer(screenTapped)
        
        hrDatePicker.datePickerMode = .dateAndTime
        hrDatePicker.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: .valueChanged)
        bpmTextField.delegate = self
        startDateTextField.delegate = self
        endDateTextField.delegate = self
        createToolBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        resetTextFieldColor()
    }
    
    @objc func datePickerChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        if endDateTextField.isEditing {
            endDateTextField.text = dateFormatter.string(from: hrDatePicker.date)
        } else if startDateTextField.isEditing {
            startDateTextField.text = dateFormatter.string(from: hrDatePicker.date)
        }
    }
    
    @objc func dismissInputKeys() {
        view.endEditing(true)
    }
    
    @objc func dismissKeys(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Create 
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        resetTextFieldColor()
        
        guard let bpmHR = bpmTextField.text, !bpmHR.isEmpty,
            let endDate = endDateTextField.text, !endDate.isEmpty,
            let startDate = startDateTextField.text, !startDate.isEmpty else {
                let textFieldErrorNotif = AlertController.presentAlertControllerWith(alertTitle: "Error Saving Your Record", alertMessage: "Ensure that all the fields are filled out correctly", dismissActionTitle: "OK")
                DispatchQueue.main.async {
                    self.present(textFieldErrorNotif, animated: true, completion: nil)
                }
                return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        guard let startDateObject = dateFormatter.date(from: startDate),
            let endDateObject = dateFormatter.date(from: endDate),
            let bpmHearRateDouble = Double(bpmHR) else {
                return
        }
        
        //Logic to ensure that the start date comes before the end date
        if startDateObject >= endDateObject {
            let timeIssueAlert = AlertController.presentAlertControllerWith(alertTitle: "Incorrect Time", alertMessage: "Ensure that your start date is before your end date", dismissActionTitle: "Ok")
            DispatchQueue.main.async {
                self.present(timeIssueAlert, animated: true, completion: nil)
            }
            accentedTextFields()
            return
        } else {
            
            HeartViewModel.sharedInstance.createHearRateWith(hrBPM: bpmHearRateDouble, startDate: startDateObject, endDate: endDateObject) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(_):
                    let errorSavingNotif = AlertController.presentAlertControllerWith(alertTitle: "Error Occurred", alertMessage: "There was an error saving your record, ensure that your device is linked to your Health app and appropriate permissions are granted", dismissActionTitle: "Ok")
                    DispatchQueue.main.async {
                        self.present(errorSavingNotif, animated: true, completion: nil)
                    }
                    print(HealthKitResult.error.localizedDescription)
                }
            }
        }
    }
}

extension HeartRateDetailController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case startDateTextField:
            startDateTextField.inputView = hrDatePicker
            startDateTextField.inputAccessoryView = toolBar
        case endDateTextField:
            endDateTextField.inputView = hrDatePicker
            endDateTextField.inputAccessoryView = toolBar
        case bpmTextField:
            bpmTextField.keyboardType = .numberPad
        default:
            break
        }
        return true
    }
}

// MARK: - Tool Bar 

extension HeartRateDetailController {
    func createToolBar() {
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(sender:)))
        
        let toolBarLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/3, height: 40))
        toolBarLabel.text = "Select Your Date"
        
        let labelButton = UIBarButtonItem(customView:toolBarLabel)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.setItems([flexibleSpace,labelButton,flexibleSpace,doneButton], animated: true)
    }
    
    
    @objc func doneButtonPressed(sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        if endDateTextField.isEditing  {
            endDateTextField.text = dateFormatter.string(from: hrDatePicker.date)
            endDateTextField.resignFirstResponder()
        } else if startDateTextField.isEditing    {
            startDateTextField.text = dateFormatter.string(from: hrDatePicker.date)
            startDateTextField.resignFirstResponder()
        }
    }
}

extension HeartRateDetailController {
    func accentedTextFields() {
        DispatchQueue.main.async {
            self.startDateTextField.backgroundColor = .lightGray
            self.endDateTextField.backgroundColor = .lightGray
        }
    }
    
    func resetTextFieldColor() {
        DispatchQueue.main.async {
            self.startDateTextField.backgroundColor = .clear
            self.endDateTextField.backgroundColor = .clear
        }
    }
}
