//
//  JournalButtonsSectionView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct JournalButtonsSectionView: View {
    @EnvironmentObject private var state: TherapyState

    var body: some View {
        JournalButtonsSection(
            showJournalIntro: $state.showJournalIntro,
            showVoiceJournal: $state.showVoiceJournal,
            speechPermissionDenied: $state.speechPermissionDenied
        )
    }
}
