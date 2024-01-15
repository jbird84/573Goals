//
//  MeasureGoalVC.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import UIKit
import DZNEmptyDataSet


class MeasureGoalVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var barNavItem: UINavigationItem!
    
    var currentGoal: GoalEntity?
    var measureGoals: [MeasureEntity] = []
    var currentMeasuredGoals: [MeasureEntity] = []
    var coreDataManager: CoreDataManager!
    var total: Int64 = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getReps()
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
    
    private func getReps() {
        //fetch entities
        let result = coreDataManager.fetch(MeasureEntity.self)
        
        switch result {
        case .success(let entities):
            if !entities.isEmpty {
                measureGoals = entities
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
        let goalId = currentGoal?.id
        currentMeasuredGoals = measureGoals.filter { $0.id == goalId }
        
        // Sort currentMeasuredGoals based on date in ascending order
        currentMeasuredGoals.sort { $0.date.compare($1.date) == .orderedAscending }
        
        self.total = currentMeasuredGoals.reduce(0) { $0 + $1.reps }
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let selectedDate = dateFormatter.string(from: currentMeasuredGoals[indexPath.row].date)
        cell.dateLabel.text = selectedDate
        cell.repsLabel.text = String(currentMeasuredGoals[indexPath.row].reps)
        totalLabel.text = String(total)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            K.showAlertWithDeleteAction(title: "Selected Goal Measurement Will Be Deleted", message: "Are you sure you want to delete this measurement?", presentingViewController: self) { [weak self] _ in
                guard let self = self else { return }
                
                // Get the MeasureEntity to be deleted
                let goalMeasurementToDelete = self.currentMeasuredGoals[indexPath.row]
                
                // Fetch MeasureEntity instances for deletion
                switch coreDataManager.fetch(MeasureEntity.self, predicate: NSPredicate(format: "id == %@", goalMeasurementToDelete.id as NSNumber)) {
                case .success(let measurementEntities):
                    if let goalMeasurementEntityToDelete = measurementEntities.first {
                        
                        print("Fetched Goal Measurement Entity: \(goalMeasurementEntityToDelete)")
                        // Calculate the deleted percentage
                        let deletedPercentage: Float = (Float(goalMeasurementToDelete.reps) / Float(self.currentGoal?.amount ?? 0)) * 100.0
                        
                        // Fetch the existing GoalEntity
                        guard let goal = self.currentGoal else { return }
                        let currentGoalId: Int64 = goal.id
                        let result = coreDataManager.fetch(GoalEntity.self, predicate: NSPredicate(format: "id == %@", currentGoalId as NSNumber))
                        
                        switch result {
                        case .success(let goals):
                            guard let existingGoal = goals.first else {
                                print("Existing Goal not found")
                                return
                            }
                            
                            // Update the existing GoalEntity's percentage
                            existingGoal.percentage = goal.percentage - deletedPercentage
                            print("Updated Goal Percentage: \(existingGoal.percentage)")
                            
                            // Save the context before deletion
                            self.coreDataManager.saveContext()
                            print("Goal Measurement Entity Deleted")
                            
                            // Delete the object from Core Data
                            coreDataManager.delete(goalMeasurementEntityToDelete)
                            print("Goal Measurement Entity Deleted")
                            
                            // Update the data source
                            self.currentMeasuredGoals.remove(at: indexPath.row)
                            
                            self.total = self.total - goalMeasurementToDelete.reps
                            
                            // Update the totalLabel.text
                            self.totalLabel.text = String(self.total)
                            
                            // Animate the deletion
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                        case .failure(let error):
                            // Handle the error appropriately
                            print("Error fetching goal entities: \(error.localizedDescription)")
                        }
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
