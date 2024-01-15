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
    var total: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    @IBAction func saveRepsButtonPressed(_ sender: Any) {
        
        if let reps = repsLabel.text, !reps.isEmpty {
            guard let currentGoal = goal else { return }
            let currentGoalId: Int64 = currentGoal.id
            
            // Fetch the existing GoalEntity
            let result = coreDataManager.fetch(GoalEntity.self, predicate: NSPredicate(format: "id == %@", currentGoalId as NSNumber))
            
            switch result {
            case .success(let goals):
                guard let existingGoal = goals.first else {
                    return
                }
                
                // Update the MeasureEntity
                _ = MeasureEntity.createInManagedObjectContext(coreDataManager.managedContext, id: currentGoalId, date: datePicker.date, reps: Int64(reps) ?? 0, total: total + (Int64(reps) ?? 0))
                
                // Update the GoalEntity's percentage
                let currentPercentage: Float = (Float(reps) ?? 0.0) / Float(currentGoal.amount) * 100.0
                existingGoal.percentage += currentPercentage
                
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
    
}
