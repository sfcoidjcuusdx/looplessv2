import SwiftUI
import Lottie

struct ProgressDetailView: View {
    @ObservedObject var evaluator: RewardsEvaluator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerView

                ForEach(evaluator.goals) { goal in
                    goalCard(for: goal)
                }

                Spacer()
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color.black, Color.blue.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Subviews

    private var headerView: some View {
        Text("Your Progress")
            .font(.largeTitle.bold())
            .foregroundStyle(
                LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
            )
            .padding(.top, 12)
    }

    private func goalCard(for goal: GoalMetric) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.icon)
                    .foregroundColor(.cyan)
                Text(goal.title)
                    .font(.headline)
            }

            ProgressView(value: goal.progress, total: goal.target)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)

            Text(goal.progressText)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(goalBackground)
    }

    private var goalBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.03))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.blue.opacity(0.4), .cyan.opacity(0.3)],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Metric Model

struct GoalMetric: Identifiable {
    let id: String
    let title: String
    let icon: String
    let progress: Double
    let target: Double

    var progressText: String {
        guard target != 0 else { return "0%" }
        let percent = (progress / target) * 100
        return String(format: "%.0f%%", min(percent, 100))
    }
}

