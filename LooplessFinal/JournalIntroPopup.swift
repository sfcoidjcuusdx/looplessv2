//
//  JournalIntroPopup.swift
//  loopless
//
//  Created by rafiq kutty on 6/29/25.
//


import SwiftUI

struct JournalIntroPopup: View {
    @Environment(\.dismiss) var dismiss
    @Binding var navigateToJournal: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("📝 Why Journal?")
                .font(.custom("Avenir Next", size: 24).weight(.bold))
                .foregroundColor(.white)

            Text("Journaling helps you recognize thought patterns, identify emotional triggers, and reflect on your screen usage. It's a core CBT technique to boost awareness and improve habits.")
                .font(.custom("Avenir Next", size: 16))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding()

            Button("Start Journaling") {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    navigateToJournal = true
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .font(.custom("Avenir Next", size: 18).weight(.semibold))
        }
        .padding()
        .background(Color.black)
        .cornerRadius(24)
        .padding()
    }
}
