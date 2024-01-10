//
//  ViewController.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import UIKit
import DZNEmptyDataSet

class GoalsListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barNavItem: UINavigationItem!
    
    var goals: [GoalEntity] = []
        var coreDataManager: CoreDataManager!

        // Add the delegate property
        weak var delegate: MeasureGoalDelegate?

        override func viewDidLoad() {
            super.viewDidLoad()
            setupView()
            
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let sqliteFilePath = documentDirectory.appendingPathComponent("YourCoreDataModel.sqlite").path
                print("SQLite File Path: \(sqliteFilePath)")
            }
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            getGoals()
            updateProgressBarsForAllGoals()
        }

        private func updateProgressBarsForAllGoals() {
            for goal in goals {
                //let totalReps = getRepsForGoal(goal)
                //let updatedPercentage = totalReps > 0 ? Float(totalReps) / Float(goal.amount) : 0.0
                delegate?.didUpdateMeasurement(for: goal, with: goal.percentage)
            }
        }

        private func getRepsForGoal(_ goal: GoalEntity) -> Int64 {
            let result = coreDataManager.fetch(MeasureEntity.self, predicate: NSPredicate(format: "id == %@", goal.id as NSNumber))

            switch result {
            case .success(let entities):
                return entities.reduce(0) { $0 + $1.reps }
            case .failure(let error):
                print("Error fetching goal measurements for \(goal.name): \(error.localizedDescription)")
                return 0
            }
        }

        private func setupView() {
            let addNewGoalButton = UIBarButtonItem(image: UIImage(systemName:"plus"), style: .plain, target: self, action: #selector(addNewGoal))
            barNavItem.rightBarButtonItem = addNewGoalButton
            title = "My Goals"

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("AppDelegate not found")
            }
            coreDataManager = appDelegate.coreDataManager
            
            // Set the delegate here
            delegate = self
            tableView.dataSource = self
            tableView.delegate = self
            tableView.emptyDataSetSource = self
            tableView.emptyDataSetDelegate = self
        }

        private func getGoals() {
            let result = coreDataManager.fetch(GoalEntity.self)

            switch result {
            case .success(let entities):
                if !entities.isEmpty {
                    self.goals = entities.map { entity in
                        return Goal(id: entity.id, month: entity.month ?? "No Data", amount: entity.amount, name: entity.name ?? "No Data")
                    }
                    tableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching bags: \(error.localizedDescription)")
                K.showAlert(title: "Error", message: "Failed to fetch goals. Please try again later.", presentingViewController: self)
            }
        }

        @objc func addNewGoal() {
            let vc = UIStoryboard(name: "AddGoal", bundle: nil).instantiateViewController(withIdentifier: "addGoal") as! AddGoalVC
            navigationController?.pushViewController(vc, animated: true)
        }
    }

extension GoalsListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goalsListCell", for: indexPath) as! GoalsListCell
        cell.GoalNameLabel.text = goals[indexPath.row].name
        cell.goalAmountLabel.text = String(goals[indexPath.row].amount)
        cell.monthLabel.text = goals[indexPath.row].month
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            K.showAlertWithDeleteAction(title: "Selected Goal Will Be Deleted", message: "Are you sure you want to delete this goal?", presentingViewController: self) { [weak self] _ in
                guard let self = self else { return }
                
                // Get the BagDataModel to be deleted
                let goalToDelete = self.goals[indexPath.row]
                
                // Fetch BagEntity instances for deletion
                switch coreDataManager.fetch(GoalEntity.self, predicate: NSPredicate(format: "id == %@", goalToDelete.id as NSNumber)) {
                case .success(let goalEntities):
                    if let goalEntityToDelete = goalEntities.first {
                        // Delete the object from Core Data
                        coreDataManager.delete(goalEntityToDelete)
                        
                        // Update the data source and table view
                        self.goals.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        tableView.reloadData()
                    }
                case .failure(let error):
                    // Handle the error appropriately, e.g., show an alert or log the error
                    print("Error fetching goal entities for deletion: \(error.localizedDescription)")
                    K.showAlert(title: "Error", message: "Failed to delete goal. Please try again later.", presentingViewController: self)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goal = goals[indexPath.item]
        
        let storyboard = UIStoryboard(name: "MeasureGoal", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "measureGoalVC") as? MeasureGoalVC {
            vc.currentGoal = goal
           // vc.delegate = self // Set the delegate
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension GoalsListVC: MeasureGoalDelegate {
    func didUpdateMeasurement(for goal: GoalEntity, with percentage: Float) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? GoalsListCell {
                cell.updateProgressBar(with: percentage)
            }
        }
    }
}

extension GoalsListVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "noGoal")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Goals Found"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap the + button above to create your first goal."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
}



