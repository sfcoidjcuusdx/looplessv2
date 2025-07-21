//
//  CBTChallengeSheet.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/17/25.
//


import SwiftUI

struct CBTChallengeSheet: View {
    @State private var completedChallenges: Set<String> = []

    let challenges = [
        "Write down 3 positive things about today",
        "Identify a distorted thought and reframe it",
        "Take a 10-min mindfulness break",
        "Practice gratitude for 5 minutes",
        "Do a 2-min breathing exercise"
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(challenges, id: \.self) { challenge in
                    HStack {
                        Image(systemName: completedChallenges.contains(challenge) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(completedChallenges.contains(challenge) ? .green : .gray)
                            .onTapGesture {
                                toggle(challenge)
                            }
                        Text(challenge)
                            .font(.body)
                    }
                }
            }
            .navigationTitle("Complete a Challenge")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                    }
                }
            }
        }
    }

    func toggle(_ challenge: String) {
        if completedChallenges.contains(challenge) { return }

        completedChallenges.insert(challenge)
        let points = UserDefaults.standard.integer(forKey: "cbtPoints")
        UserDefaults.standard.set(points + 25, forKey: "cbtPoints")

        print("✅ Earned 25 points for completing: \(challenge)")
    }
}
