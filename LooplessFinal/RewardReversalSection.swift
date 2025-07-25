//
//  RewardReversalSection.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct RewardReversalSection: View {
    @Binding var rewardChecks: [RewardRealityCheckActivity.RewardCheck]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Your Reward Reversals", systemImage: "checkmark.seal")
                    .font(.headline)
                Spacer()
                NavigationLink("Add New", destination: RewardRealityCheckActivity())
                    .font(.caption)
            }

            if rewardChecks.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Analyze the true costs of your digital habits and find better alternatives.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    NavigationLink("Create Reward Reversal", destination: RewardRealityCheckActivity())
                        .buttonStyle(.bordered)
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(rewardChecks.prefix(3)) { check in
                        RewardReversalPreview(check: check)
                    }

                    if rewardChecks.count > 3 {
                        NavigationLink("View All (\(rewardChecks.count))", destination: FullRewardReversalsList(checks: rewardChecks))
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct RewardReversalPreview: View {
    let check: RewardRealityCheckActivity.RewardCheck

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(check.habit).font(.headline)
                Spacer()
                Text(check.lastEdited.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let reward = check.perceivedRewards.first,
               let cost = check.actualCosts.first,
               let alternative = check.betterAlternatives.first {
                VStack(alignment: .leading, spacing: 4) {
                    Label(reward, systemImage: "arrow.down.right").font(.caption)
                    Label(cost, systemImage: "arrow.up.right").font(.caption)
                    Label(alternative, systemImage: "arrow.uturn.up").font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}

struct FullRewardReversalsList: View {
    let checks: [RewardRealityCheckActivity.RewardCheck]

    var body: some View {
        List {
            ForEach(checks) { check in
                NavigationLink(destination: RewardRealityCheckActivity()) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(check.habit).font(.headline)
                        Text("Last updated: \(check.lastEdited.formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("All Reward Reversals")
    }
}
