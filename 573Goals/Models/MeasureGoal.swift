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
    
    @NSManaged public var id: Double
    @NSManaged public var date: Date
    @NSManaged public var reps: Double
    @NSManaged public var total: Double
    
    class func createInManagedObjectContext(_ context: NSManagedObjectContext, id: Double, date: Date, reps: Double, total: Double) -> MeasureEntity {
        let newMeasureEntity = NSEntityDescription.insertNewObject(forEntityName: "MeasureEntity", into: context) as! MeasureEntity
        newMeasureEntity.id = id
        newMeasureEntity.date = date
        newMeasureEntity.reps = reps
        newMeasureEntity.total = Double(total)
        
        return newMeasureEntity
    }
}



