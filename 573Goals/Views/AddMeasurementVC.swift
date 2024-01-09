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
    var goal: Goal?
    var total: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setupView()
    }
    
    @IBAction func saveRepsButtonPressed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let selectedDate = dateFormatter.string(from: datePicker.date)
       
        if let reps = repsLabel.text, !reps.isEmpty {
            if let newEntity = NSEntityDescription.insertNewObject(forEntityName: "MeasureEntity", into: coreDataManager.managedContext) as? MeasureEntity {
                guard let currentGoal = goal else { return }
                newEntity.id = currentGoal.id
                newEntity.date = selectedDate
                newEntity.reps = Int64(reps) ?? 0
                newEntity.total = total + (Int64(reps) ?? 0)
                
                coreDataManager.saveContext()
            }
            
            navigationController?.popViewController(animated: true)
            } else {
                K.showAlert(title: "Add Reps Field Empty", message: "Please fill out number of reps to log your goal.", presentingViewController: self)
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
