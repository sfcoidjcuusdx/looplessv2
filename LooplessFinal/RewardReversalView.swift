import SwiftUI

struct RewardReversalView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The Reward Reversal")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("What you think is rewarding may be the source of discomfort. This lesson explores the true cost of screen habits.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Spacer()
                    Image(systemName: "target")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.cyan)
                        .shadow(radius: 3)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Perceived vs. Real Rewards")
                            .font(.headline)
                        Text("Compare: Instagram dopamine hit vs. walk outside. Which really calms you?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Group {
                        Text("Cost Mapping")
                            .font(.headline)
                        Text("Map the cost: lost time, mood drop, regret. Make it visual.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Group {
                        Text("Values Inventory")
                            .font(.headline)
                        Text("List what brings peace and pride. Re-anchor behavior around that.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                NavigationLink(destination: RewardReversalQuizView()) {
                    Label("Take Reflection Quiz", systemImage: "checkmark.bubble")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .controlSize(.large)
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Reward Insight")
        .background(Color(.systemGroupedBackground))
    }
}

