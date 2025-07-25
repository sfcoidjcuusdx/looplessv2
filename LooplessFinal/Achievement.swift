//
//  Achievement.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  Achievement.swift
//  loopless
//
//  Created by rafiq kutty on 6/18/25.
//

import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let description: String
    let reward: Int
    let progressDescription: (Double, Double) -> String
}

struct GoalSettingCard: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let icon: String
    let color: Color
    var unit: String = ""

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.headline)
                Spacer()
                Text("\(value)\(unit.isEmpty ? "" : " \(unit)")")
            }
            Stepper("", value: $value, in: range, step: step)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let currentProgress: Double
    let isCompleted: Bool
    let target: Double

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: achievement.icon).foregroundColor(achievement.color)
                VStack(alignment: .leading) {
                    Text(achievement.title).font(.headline)
                    Text(achievement.description).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                if isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                } else {
                    Text("+\(achievement.reward)")
                        .font(.subheadline.bold())
                        .foregroundColor(achievement.color)
                }
            }
            ProgressView(value: currentProgress, total: target) {
                Text(achievement.progressDescription(currentProgress, target))
                    .font(.caption)
            }
            .tint(achievement.color)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

