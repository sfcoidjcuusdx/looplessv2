//
//  LoopMappingSectionView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct LoopMappingSectionView: View {
    @EnvironmentObject private var state: TherapyState

    var body: some View {
        LoopMappingSection(
            savedTrigger: state.savedTrigger,
            savedBehavior: state.savedBehavior,
            savedOutcome: state.savedOutcome
        )
    }
}
