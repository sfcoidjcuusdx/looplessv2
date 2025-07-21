//
//  BlockedApp.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  BlockedApp.swift
//  loopless
//
//  Created by rafiq kutty on 6/18/25.
//


import SwiftUI

struct BlockedApp: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
}

class BlockerViewModel: ObservableObject {
    @Published var blockedApps: [BlockedApp] = []

    func awardMobiusStrips(_ amount: Int) {
        print("Awarded \(amount) Mobius Strips")
    }
}