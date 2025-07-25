import SwiftUI

struct MetricSummaryView: View {
    let summary: MetricSummary

    var body: some View {
        // Format usage as "1h 30m" instead of "90 min"
        let totalMinutes = Int(summary.usageStability / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        let usageString = hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"

        // Determine impulse score and color
        let impulseScore = summary.impulseControl * 100
        let impulseColor: Color = impulseScore >= 60 ? .green : (impulseScore <= 40 ? .red : .primary)

        // Determine usage color based on healthy screen time
        let usageColor: Color = totalMinutes < 120 ? .green : (totalMinutes > 240 ? .red : .primary)

        VStack(spacing: 16) {
            HStack(spacing: 16) {
                insightCard(
                    title: "Mindfulness",
                    value: String(format: "%.0f%%", impulseScore),
                    valueColor: impulseColor
                )

                insightCard(
                    title: "Daily Avg",
                    value: usageString,
                    valueColor: usageColor
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.white.ignoresSafeArea())
    }

    private func insightCard(title: String, value: String, valueColor: Color = .primary) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 4)
        )
    }
}

