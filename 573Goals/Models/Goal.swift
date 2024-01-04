//
//  Goal.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import UIKit


struct Goal {
    let id: Int64
    let month: String
    let amount: Int64
    let name: String
    
    
    init(id: Int64, month: String, amount: Int64, name: String) {
        self.id = id
        self.month = month
        self.amount = amount
        self.name = name
    }
}
