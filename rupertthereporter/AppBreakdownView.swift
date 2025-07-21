import SwiftUI
import Charts

struct AppBreakdownView: View {
    let usageByHour: [HourlyUsage]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                Text("Usage by Hour")
                    .font(.custom("AvenirNext-Medium", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal)

                if usageByHour.isEmpty {
                    Text("No usage recorded.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                } else {
                    Chart {
                        ForEach(usageByHour) { entry in
                            BarMark(
                                x: .value("Hour", entry.hour),
                                y: .value("Minutes", entry.duration / 60)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color(hue: 0.6, saturation: 1.0, brightness: 0.4)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(5)
                        }
                    }
                    .chartPlotStyle { plotArea in
                        plotArea
                            .padding(.leading, 12) // Prevents bar/axis overlap
                    }

                    .chartXAxis {
                        AxisMarks(values: .stride(by: 2))
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: geometry.size.height * 0.7) // dynamically scale with container
                    .padding(.horizontal)
                }
            }
            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.black, Color.black.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.6)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    AppBreakdownView(usageByHour: [
        HourlyUsage(hour: 9, duration: 1800),
        HourlyUsage(hour: 10, duration: 2400),
        HourlyUsage(hour: 13, duration: 3600),
        HourlyUsage(hour: 16, duration: 900),
        HourlyUsage(hour: 20, duration: 2400)
    ])
    .frame(height: 240)
}

