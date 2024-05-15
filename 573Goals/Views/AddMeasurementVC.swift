//
//  AddMeasurementVC.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import UIKit
import CoreData

class AddMeasurementVC: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var repsLabel: UITextField!
    
    var coreDataManager: CoreDataManager!
    var goal: GoalEntity?
    var total: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    @IBAction func saveRepsButtonPressed(_ sender: Any) {
        
        if let reps = repsLabel.text, !reps.isEmpty {
            guard let currentGoal = goal else { return }
            let currentGoalId: Double = currentGoal.id
            
            // Fetch the existing GoalEntity
            let result = coreDataManager.fetch(GoalEntity.self, predicate: NSPredicate(format: "id == %@", currentGoalId as NSNumber))
            
            switch result {
            case .success(let goals):
                guard let existingGoal = goals.first else {
                    return
                }
                
                //Round the reps value to one decimal place
                let roundedReps = roundStringToDouble(reps) ?? 0
                
                // Update the MeasureEntity
                _ = MeasureEntity.createInManagedObjectContext(coreDataManager.managedContext, id: currentGoalId, date: datePicker.date, reps: Double(roundedReps), total: total + (Double(roundedReps)))
                
                // Update the GoalEntity's percentage
                let currentPercentage: Float = (Float(roundedReps)) / Float(currentGoal.amount) * 100.0
                
                // Round the percentage to two decimal places (adjust as needed)
                let roundedPercentage = round(currentPercentage * 100) / 100

                existingGoal.percentage += roundedPercentage
                
                // Save the context
                coreDataManager.saveContext()
                
                navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                print("Error fetching goal entities: \(error.localizedDescription)")
                // Handle the error appropriately
            }
        } else {
            K.showAlert(title: "Add Reps Field Empty", message: "Please fill out the number of reps to log your goal.", presentingViewController: self)
        }
    }
    
    private func setupView() {
        title = "Add Reps To Your Goal"
        
        // Access the shared instance of CoreDataManager from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        coreDataManager = appDelegate.coreDataManager
    }
    
    func roundStringToDouble(_ str: String) -> Double? {
        let decimalNumber = NSDecimalNumber(string: str)
        let roundingBehavior = NSDecimalNumberHandler(roundingMode: .plain, scale: 1, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let roundedNumber = decimalNumber.rounding(accordingToBehavior: roundingBehavior)
        return roundedNumber.doubleValue
    }
}
