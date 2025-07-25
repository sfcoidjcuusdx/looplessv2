import SwiftUI

struct CoreValuesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Core Values & Future Self")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Clarify your deeper values. Anchor your digital choices in your future self.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Spacer()
                    Image(systemName: "sparkles")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.cyan)
                        .shadow(radius: 3)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Identity Anchors")
                            .font(.headline)
                        Text("Who do you want to become? Map your identity through actions.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Group {
                        Text("Value Clarification")
                            .font(.headline)
                        Text("Choose top 3 values: Integrity, Presence, Growth, etc. Write them visibly.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Group {
                        Text("Future Self Visualization")
                            .font(.headline)
                        Text("Visualize a day in the life of your ideal future self. How do they relate to tech?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                NavigationLink(destination: CoreValuesQuizView()) {
                    Label("Explore Core Values Quiz", systemImage: "list.bullet.clipboard")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .controlSize(.large)
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Your Values")
        .background(Color(.systemGroupedBackground))
    }
}

