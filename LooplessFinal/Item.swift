//
//  Item.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/7/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
