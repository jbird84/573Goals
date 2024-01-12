//
//  MeasureGoal.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import Foundation
import CoreData

@objc(MeasureEntity)
class MeasureEntity: NSManagedObject {
    
    @NSManaged public var id: Int64
    @NSManaged public var date: String
    @NSManaged public var reps: Int64
    @NSManaged public var total: Int64
    
    class func createInManagedObjectContext(_ context: NSManagedObjectContext, id: Int64, date: String, reps: Int64, total: Int64) -> MeasureEntity {
        let newMeasureEntity = NSEntityDescription.insertNewObject(forEntityName: "GoalEntity", into: context) as! MeasureEntity
        newMeasureEntity.id = id
        newMeasureEntity.date = date
        newMeasureEntity.reps = reps
        newMeasureEntity.total = Int64(total)
        
        return newMeasureEntity
    }
}



