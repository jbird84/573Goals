//
//  MeasureGoal.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import Foundation


struct MeasureGoal {
    let id: Int64
    let date: String
    let reps: Int64
    let total: Int64
    
    
    init(id: Int64, date: String, reps: Int64, total: Int64) {
        self.id = id
        self.date = date
        self.reps = reps
        self.total = total
    }
}
