//
//  RewardReversalSectionView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct RewardReversalSectionView: View {
    @EnvironmentObject private var state: TherapyState

    var body: some View {
        RewardReversalSection(rewardChecks: $state.rewardChecks)
    }
}
