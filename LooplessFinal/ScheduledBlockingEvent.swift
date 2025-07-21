//
//  ScheduledBlockingEvent.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/10/25.
//


import Foundation
import FamilyControls

struct ScheduledBlockingEvent: Identifiable, Codable {
    let id = UUID()
    let name: String
    let day: String
    let start: DateComponents
    let end: DateComponents
    let selectionData: Data

    var selection: FamilyActivitySelection? {
        try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: selectionData)
    }
}
