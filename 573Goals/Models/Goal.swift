//
//  Goal.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import UIKit
import CoreData


@objc(GoalEntity)
public class GoalEntity: NSManagedObject {
    
    @NSManaged public var id: Double
    @NSManaged public var month: String
    @NSManaged public var amount: Double
    @NSManaged public var name: String
    @NSManaged public var percentage: Float
    
    
    class func createInManagedObjectContext(_ context: NSManagedObjectContext, id: Double, month: String, amount: Double, name: String, percentage: Float) -> GoalEntity {
         let newGoalEntity = NSEntityDescription.insertNewObject(forEntityName: "GoalEntity", into: context) as! GoalEntity
            newGoalEntity.id = id
            newGoalEntity.month = month
            newGoalEntity.name = name
            newGoalEntity.amount = Double(amount)
            newGoalEntity.percentage = percentage
            
            return newGoalEntity
        }
}
