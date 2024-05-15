//
//  EditMeasureGoalVC.swift
//  573Goals
//
//  Created by Kinney Kare on 1/15/24.
//

import UIKit

class EditMeasureGoalVC: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var repsTextField: UITextField!
    
    var measureGoal: MeasureEntity?
    var goal: GoalEntity?
    var total: Double = 0
    
    var coreDataManager: CoreDataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        title = "Update Goal"
        // Access the shared instance of CoreDataManager from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        coreDataManager = appDelegate.coreDataManager
        guard let mg = measureGoal else { return }
        datePicker.date = mg.date
        repsTextField.placeholder = String(mg.reps)
    }
    
    
    @IBAction func updateRepsButtonPressed(_ sender: Any) {
        guard let currentGoal = goal, let selectedMeasure = measureGoal else { return }
        let _: Double = currentGoal.id
        
        // Calculate the previous percentage contribution of the old reps
        let previousPercentage: Float = Float(selectedMeasure.reps) / Float(currentGoal.amount) * 100.0
        
        // Update the MeasureEntity
        selectedMeasure.reps = Double(repsTextField.text ?? "") ?? 0
        selectedMeasure.total = total + (Double(repsTextField.text ?? "") ?? 0)
        selectedMeasure.date = datePicker.date
        
        // Calculate the new percentage contribution of the new reps
        let newPercentage: Float = Float(selectedMeasure.reps) / Float(currentGoal.amount) * 100.0
        
        // Round the percentage to two decimal places (adjust as needed)
        let roundedPercentage = round(newPercentage * 100) / 100
        
        // Update the GoalEntity's percentage by subtracting the previous and adding the new percentage
        currentGoal.percentage = currentGoal.percentage - previousPercentage + roundedPercentage
        
        // Save the context
        coreDataManager.saveContext()
        
        navigationController?.popViewController(animated: true)
    }
}


