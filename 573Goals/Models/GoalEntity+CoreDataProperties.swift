//
//  GoalEntity+CoreDataProperties.swift
//  573Goals
//
//  Created by Kinney Kare on 1/6/24.
//
//

import Foundation
import CoreData


extension GoalEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalEntity> {
        return NSFetchRequest<GoalEntity>(entityName: "GoalEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var month: String?
    @NSManaged public var name: String?
    @NSManaged public var amount: Int64
    @NSManaged public var measurement: MeasureEntity?

}

extension GoalEntity : Identifiable {

}
