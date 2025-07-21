//
//  ApplicationProfile.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/15/25.
//


import Foundation
import ManagedSettings

struct ApplicationProfile: Codable, Hashable {
    let id: UUID
    let applicationToken: ApplicationToken
    
    init(id: UUID = UUID(), applicationToken: ApplicationToken) {
        self.applicationToken = applicationToken
        self.id = id
    }
}