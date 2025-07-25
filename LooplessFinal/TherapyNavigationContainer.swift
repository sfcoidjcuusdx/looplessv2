//
//  TherapyNavigationContainer.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct TherapyNavigationContainer<Content: View>: View {
    @Binding var showReflectionPopup: Bool
    @ObservedObject var therapyState: TherapyState
    let content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .navigationTitle("Therapy Lessons")
                .background(Color(.systemGroupedBackground))
                .navigationDestination(isPresented: $therapyState.navigateToJournal) {
                    JournalView()
                }
                .sheet(isPresented: $therapyState.showVisionBoardFullScreen) {
                    VisionBoardSheet(board: therapyState.visionBoard)
                }
                .sheet(isPresented: $therapyState.showJournalIntro) {
                    JournalIntroPopup(navigateToJournal: $therapyState.navigateToJournal)
                }
                .sheet(isPresented: $therapyState.showVoiceJournal) {
                    VoiceJournalView()
                }
        }
        .fullScreenCover(isPresented: $showReflectionPopup) {
            ReflectionPopupView {
                showReflectionPopup = false
            }
        }
        .environmentObject(therapyState)
    }
}
