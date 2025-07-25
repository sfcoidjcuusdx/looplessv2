//
//  JournalButtonsSection.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI
import Speech

struct JournalButtonsSection: View {
    @Binding var showJournalIntro: Bool
    @Binding var showVoiceJournal: Bool
    @Binding var speechPermissionDenied: Bool

    var body: some View {
        VStack(spacing: 12) {
            Button {
                showJournalIntro = true
            } label: {
                Label("Open Journal", systemImage: "book.closed")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                SFSpeechRecognizer.requestAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            showVoiceJournal = true
                        default:
                            speechPermissionDenied = true
                        }
                    }
                }
            } label: {
                Label("Voice Journal", systemImage: "mic")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            if speechPermissionDenied {
                Text("Speech recognition permission denied. Please enable it in Settings.")
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
    }
}
