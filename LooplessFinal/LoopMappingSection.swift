//
//  LoopMappingSection.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct LoopMappingSection: View {
    let savedTrigger: String
    let savedBehavior: String
    let savedOutcome: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Your Behavior Loop", systemImage: "arrow.triangle.branch")
                    .font(.headline)
                Spacer()
                NavigationLink("Edit", destination: LoopMappingExercise())
                    .font(.caption)
            }

            if !savedTrigger.isEmpty && !savedBehavior.isEmpty && !savedOutcome.isEmpty {
                Text("\(savedTrigger) → \(savedBehavior) → \(savedOutcome)")
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .font(.body)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Identify your trigger-behavior-outcome loops to gain awareness")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    NavigationLink("Map Your Loop", destination: LoopMappingExercise())
                        .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}
