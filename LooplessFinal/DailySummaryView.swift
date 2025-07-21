import SwiftUI

struct DailySummaryView: View {
    @ObservedObject var stopwatch: StopwatchManager
    @ObservedObject var screenTimeData = ScreenTimeData.shared
    @State private var animateContent = false
    @State private var showMetricInfo: String?

    var body: some View {
        VStack(spacing: 20) {
            // 📊 Sleek Metric Cards
            HStack(spacing: 10) {
                MetricCard(
                    icon: "flame.fill",
                    title: "Momentum Index",
                    value: screenTimeData.hasEnoughData ? screenTimeData.weekOverWeekChangeText : "--",
                    color: screenTimeData.weekOverWeekChangeColor,
                    gradient: Gradient(colors: [.purple, .blue]),
                    explanation: "Not enough data to compare this week to last.\n\nCompares your total screen time this week to last week. Lower is better."
                ) {
                    if !screenTimeData.hasEnoughData {
                        showMetricInfo = "Not enough data to compare this week to last.\n\nCompares your total screen time this week to last week. Lower is better."
                    }
                }

                MetricCard(
                    icon: "waveform.path.ecg",
                    title: "Usage Stability",
                    value: screenTimeData.hasEnoughData ? screenTimeData.sevenDayAverageText : "--",
                    color: .orange,
                    gradient: Gradient(colors: [.orange, .yellow]),
                    explanation: "7 full days of screen time are needed to compute an average.\n\nYour average daily screen time over the past 7 days. Consistency is key."
                ) {
                    if !screenTimeData.hasEnoughData {
                        showMetricInfo = "7 full days of screen time are needed to compute an average.\n\nYour average daily screen time over the past 7 days. Consistency is key."
                    }
                }

                MetricCard(
                    icon: "eye.slash.circle.fill",
                    title: "Impulse Control",
                    value: screenTimeData.hasEnoughData ? screenTimeData.todayVsAverageText : "--",
                    color: screenTimeData.todayVsAverageColor,
                    gradient: Gradient(colors: [.green, .mint]),
                    explanation: "We need at least 7 past days of screen time to compare today's value.\n\nHow today’s screen time compares to your 7-day average. A drop signals stronger control."
                ) {
                    if !screenTimeData.hasEnoughData {
                        showMetricInfo = "We need at least 7 past days of screen time to compare today's value.\n\nHow today’s screen time compares to your 7-day average. A drop signals stronger control."
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(0.92)
            .opacity(animateContent ? 1 : 0)
            .animation(.easeInOut(duration: 0.5).delay(0.3), value: animateContent)

            Spacer(minLength: 0)
        }
        .padding(.top)
        .padding(.horizontal)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            stopwatch.start()
            screenTimeData.loadData()

            if Calendar.current.component(.hour, from: Date()) != 0 {
                screenTimeData.recordPreviousDayIfNeeded(currentStopwatchSeconds: stopwatch.elapsedTime)
            }

            stopwatch.onDayChange = { previousDayElapsedTime in
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!
                screenTimeData.recordElapsedTime(for: yesterday, seconds: previousDayElapsedTime)
                screenTimeData.loadData()
            }

            animateContent = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            stopwatch.didEnterBackground()
            screenTimeData.recordPreviousDayIfNeeded(currentStopwatchSeconds: stopwatch.elapsedTime)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            stopwatch.willEnterForeground()
        }
        .alert(item: $showMetricInfo) { info in
            Alert(title: Text("Metric Info"), message: Text(info), dismissButton: .default(Text("Got it")))
        }
    }
}

// 📦 Sleek MetricCard Component with shimmer border
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

// 📦 Alert Binding Helper
extension String: Identifiable {
    public var id: String { self }
}

