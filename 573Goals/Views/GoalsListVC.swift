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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Documents Directory: \(documentsDirectory.path)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGoals()
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    private func getGoals() {
        print("GET GOALS")
        let result = coreDataManager.fetch(GoalEntity.self)
        
        switch result {
        case .success(let entities):
            if !entities.isEmpty {
                self.goals = entities
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
        print("Number of Rows: \(goals.count)")
        return goals.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Cell for Row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "goalsListCell", for: indexPath) as! GoalsListCell
        print(goals[indexPath.row].id)
        cell.GoalNameLabel.text = goals[indexPath.row].name
        cell.goalAmountLabel.text = String(goals[indexPath.row].amount)
        cell.monthLabel.text = goals[indexPath.row].month
        let percentage = goals[indexPath.row].percentage
        cell.updateProgressBar(with: percentage)
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
            navigationController?.pushViewController(vc, animated: true)
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



