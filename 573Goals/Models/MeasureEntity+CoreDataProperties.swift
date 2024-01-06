//
//  MeasureEntity+CoreDataProperties.swift
//  573Goals
//
//  Created by Kinney Kare on 1/6/24.
//
//

import Foundation
import CoreData


extension MeasureEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeasureEntity> {
        return NSFetchRequest<MeasureEntity>(entityName: "MeasureEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var date: String?
    @NSManaged public var reps: Int64
    @NSManaged public var total: Int64
    @NSManaged public var goals: GoalEntity?

}

extension MeasureEntity : Identifiable {

}
