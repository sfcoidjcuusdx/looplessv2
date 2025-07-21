import SwiftUI

struct MetricSummaryView: View {
    let summary: MetricSummary
    @State private var animateContent = false
    @State private var showMetricInfo: String?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 16) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        MetricCard(
                            icon: "flame.fill",
                            title: "Momentum Index",
                            value: String(format: "%.0f%%", summary.momentumIndex * 100),
                            color: .purple,
                            gradient: Gradient(colors: [.purple, .blue]),
                            explanation: "Momentum Index tracks your screen time trend across this week. A negative percentage means your screen time is dropping daily—a good sign of momentum. A positive percentage means it's rising each day, suggesting habits might be slipping."
                        ) {
                            showMetricInfo = "Momentum Index tracks your screen time trend across this week. A negative percentage means your screen time is dropping daily—a good sign of momentum. A positive percentage means it's rising each day, suggesting habits might be slipping."
                        }

                        MetricCard(
                            icon: "waveform.path.ecg",
                            title: "Usage Stability",
                            value: String(format: "%.0f min", summary.usageStability / 60),
                            color: .orange,
                            gradient: Gradient(colors: [.orange, .yellow]),
                            explanation: "Usage Stability reflects how consistent your screen time has been over the past 7 days. Lower variation suggests more balance and routine."
                        ) {
                            showMetricInfo = "Usage Stability reflects how consistent your screen time has been over the past 7 days. Lower variation suggests more balance and routine."
                        }

                        MetricCard(
                            icon: "eye.slash.circle.fill",
                            title: "Impulse Control",
                            value: String(format: "%.0f%%", summary.impulseControl * 100),
                            color: .green,
                            gradient: Gradient(colors: [.green, .mint]),
                            explanation: "Impulse Control compares today's screen time with your 7-day average. A negative number means you're using your device less than usual—indicating better control."
                        ) {
                            showMetricInfo = "Impulse Control compares today's screen time with your 7-day average. A negative number means you're using your device less than usual—indicating better control."
                        }
                    }
                    .frame(maxHeight: geo.size.height * 0.8)
                    .padding(.horizontal, 12)
                    .scaleEffect(animateContent ? 1 : 0.95)
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                    Spacer(minLength: 0)
                }
                .padding(.top)
                .background(Color.black.ignoresSafeArea())
                .onAppear {
                    animateContent = true
                }

                // MARK: - Scrollable Full-Width Explanation Overlay
                if let info = showMetricInfo {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showMetricInfo = nil
                        }

                    VStack {
                        Spacer()
                        ScrollView {
                            Text(info)
                                .font(.custom("AvenirNext-Regular", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: geo.size.height * 0.4)
                        .background(Color(.systemGray6).opacity(0.2))
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        .onTapGesture {
                            showMetricInfo = nil
                        }
                    }
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
            }
        }
    }
}

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let gradient: Gradient
    let explanation: String
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            Text(title)
                .font(.custom("AvenirNext-Regular", size: 12))
                .foregroundColor(color.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(value)
                .font(.custom("AvenirNext-DemiBold", size: 20))
                .foregroundColor(color)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 115)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onTapGesture {
            onTap()
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

