import SwiftUI

struct LoopImpulseAwarenessView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The Loop & Impulse Awareness")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Learn to identify the automatic triggers, impulses, and app loops that drive your compulsive usage.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Spacer()
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.cyan)
                        .shadow(radius: 4)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 20) {
                    SectionView(
                        title: "Trigger Awareness",
                        systemImage: "exclamationmark.bubble",
                        description: "What situations, emotions, or times of day lead to screen use? Track them over a week."
                    )

                    Divider()

                    SectionView(
                        title: "Loop Patterns",
                        systemImage: "repeat.circle",
                        description: "A loop often looks like: boredom → unlock phone → TikTok → regret → repeat. Map your top 3."
                    )

                    Divider()

                    SectionView(
                        title: "Impulse Journal",
                        systemImage: "pencil.and.outline",
                        description: "Write down each time you feel the urge to open an app. Did you act? What triggered it?"
                    )
                }

                NavigationLink(destination: LoopAwarenessQuizView()) {
                    Label("Quiz Your Loops", systemImage: "questionmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .controlSize(.large)
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Loop Awareness")
        .background(Color(.systemGroupedBackground))
    }
}



