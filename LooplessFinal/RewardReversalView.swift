//
//  RewardReversalView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  RewardReversalView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//


import SwiftUI

struct RewardReversalView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("The Reward Reversal")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundStyle(
                        LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text("What you think is rewarding may be the source of discomfort. This lesson explores the true cost of screen habits.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal)

                Image(systemName: "arrow.uturn.down")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 14) {
                    Text("🪞 Perceived vs. Real Rewards")
                        .font(.headline)
                    Text("Compare: Instagram dopamine hit vs. walk outside. Which really calms you?")
                        .font(.subheadline)

                    Text("📉 Cost Mapping")
                        .font(.headline)
                    Text("Map the cost: lost time, mood drop, regret. Make it visual.")
                        .font(.subheadline)

                    Text("🧠 Values Inventory")
                        .font(.headline)
                    Text("List what brings peace and pride. Re-anchor behavior around that.")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                NavigationLink("Take Reflection Quiz", destination: RewardReversalQuizView())
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.green)
                    .clipShape(Capsule())
            }
            .padding()
        }
        .background(LinearGradient(colors: [Color.black, Color.green.opacity(0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }
}
