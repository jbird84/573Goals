//
//  MeasureGoalVC.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import UIKit
import DZNEmptyDataSet

protocol MeasureGoalDelegate: AnyObject {
    func didUpdateMeasurement(for goal: Goal, with percentage: Float)
}

class MeasureGoalVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var barNavItem: UINavigationItem!
   
    var currentGoal: Goal = Goal(id: 0, month: "", amount: 0, name: "")
    var measureGoals: [MeasureGoal] = []
    var currentMeasuredGoals: [MeasureGoal] = []
    var coreDataManager: CoreDataManager!
    var total: Int64 = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getReps()
        updateProgressBar()
    }
    
    private func setupView() {
        let addNewGoalButton = UIBarButtonItem(image: UIImage(systemName:"plus"), style: .plain, target: self, action: #selector(addMeasurementToGoal))
        barNavItem.rightBarButtonItem = addNewGoalButton
        title = "Goal Measurements"
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        coreDataManager = appDelegate.coreDataManager
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    private func updateProgressBar() {
        total = 0 
        
        for reps in currentMeasuredGoals {
            total = total + reps.reps
        }
        
            // Calculate the updated percentage here based on your logic
        let updatedPercentage = (Float(total) / Float(currentGoal.amount))
        let predicate = NSPredicate(format: "id == %@", currentGoal.id as NSNumber)
        let result = coreDataManager.update(GoalEntity.self, predicate: predicate, attributeToUpdate: "percentage", newValue: updatedPercentage)
        }
    
    private func getReps() {
        //fetch entities
        let result = coreDataManager.fetch(MeasureEntity.self)
        
        switch result {
        case .success(let entities):
            //convert measureEntity instances to Goal instances
            if !entities.isEmpty {
                self.measureGoals = entities.map { entity in
                    return MeasureGoal(id: entity.id, date: entity.date ?? "No data",  reps: entity.reps, total: entity.total)
                }
                filterMeasuredGoalsByGoalId()
                tableView.reloadData()
            }
        case .failure(let error):
            // Handle the error appropriately, e.g., show an alert or log the error
            print("Error fetching goal measurements: \(error.localizedDescription)")
            K.showAlert(title: "Error", message: "Failed to fetch goal reps. Please try again later.", presentingViewController: self)
        }
    }
    
    private func filterMeasuredGoalsByGoalId() {
       let goalId = currentGoal.id
        currentMeasuredGoals = measureGoals.filter { $0.id == goalId }
    }
    
    @objc func addMeasurementToGoal() {
        let vc = UIStoryboard(name: "AddMeasurement", bundle: nil).instantiateViewController(withIdentifier: "addMeasurement") as! AddMeasurementVC
        vc.goal = currentGoal
        vc.total = total
        navigationController?.pushViewController(vc, animated: true)
    }

}


extension MeasureGoalVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMeasuredGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "measureGoalCell", for: indexPath) as! MeasureGoalCell
        cell.dateLabel.text = currentMeasuredGoals[indexPath.row].date
        cell.repsLabel.text = String(currentMeasuredGoals[indexPath.row].reps)
        totalLabel.text = String(currentMeasuredGoals[indexPath.row].total)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            K.showAlertWithDeleteAction(title: "Selected Goal  Measurement Will Be Deleted", message: "Are you sure you want to delete this measurement?", presentingViewController: self) { [weak self] _ in
                guard let self = self else { return }
                
                // Get the BagDataModel to be deleted
                let goalMeasurementToDelete = self.currentMeasuredGoals[indexPath.row]
                
                // Fetch BagEntity instances for deletion
                switch coreDataManager.fetch(MeasureEntity.self, predicate: NSPredicate(format: "id == %@", goalMeasurementToDelete.id as NSNumber)) {
                case .success(let measurementEntities):
                    if let goalMeasurementEntityToDelete = measurementEntities.first {
                        // Delete the object from Core Data
                        coreDataManager.delete(goalMeasurementEntityToDelete)
                        
                        // Update the data source and table view
                        self.currentMeasuredGoals.remove(at: indexPath.row)
                        self.total = total - goalMeasurementToDelete.reps
                        self.updateProgressBar()
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        tableView.reloadData()
                    }
                case .failure(let error):
                    // Handle the error appropriately, e.g., show an alert or log the error
                    print("Error fetching goal entities for deletion: \(error.localizedDescription)")
                    K.showAlert(title: "Error", message: "Failed to delete goal measurement. Please try again later.", presentingViewController: self)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension MeasureGoalVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "noGoal")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Nothing added towards this goal"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap the + button above to add some measurements."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
}
