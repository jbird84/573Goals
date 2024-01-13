//
//  AddGoalVC.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import UIKit
import CoreData

class AddGoalVC: UIViewController {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var goalAmountLabel: UITextField!
    @IBOutlet weak var goalNameLabel: UITextField!
    
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    var selectedMonth = "January"
    
    var coreDataManager: CoreDataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        title = "Create A Goal"
        picker.dataSource = self
        picker.delegate = self
        
        // Set the default selected row to January
        picker.selectRow(0, inComponent: 0, animated: false)
        
        // Access the shared instance of CoreDataManager from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        coreDataManager = appDelegate.coreDataManager
        
        // Add a tap gesture recognizer to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @IBAction func addGoalButtonTapped(_ sender: Any) {
        
        if let goalAmount = goalAmountLabel.text, !goalAmount.isEmpty {
            if let goalName = goalNameLabel.text, !goalName.isEmpty {
                // Generate a random id
                let randomId = Int64(arc4random_uniform(UInt32.max))
                let _ = GoalEntity.createInManagedObjectContext(coreDataManager.managedContext, id: randomId, month: selectedMonth, amount: Int64(goalAmount) ?? 0, name: goalName, percentage: 0.0)
                
                coreDataManager.saveContext()
                
                navigationController?.popViewController(animated: true)
            } else {
                K.showAlert(title: "Movement Name Field Empty", message: "Please fill out ALL fields before trying to save your goal.", presentingViewController: self)
            }
        } else {
            K.showAlert(title: "Goal Amount Field Empty", message: "Please fill out ALL fields before trying to save your goal.", presentingViewController: self)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Tap Gesture to Dismiss Keyboard
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension AddGoalVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return months.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return months[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMonth = months[row]
    }
    
}
