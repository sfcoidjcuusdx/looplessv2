import SwiftUI
import Charts

struct AppBreakdownView: View {
    let usageByHour: [HourlyUsage]

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 12) {
                Text("Usage by Hour")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                if usageByHour.isEmpty {
                    Text("No usage recorded.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    Chart {
                        ForEach(usageByHour) { entry in
                            BarMark(
                                x: .value("Hour", entry.hour),
                                y: .value("Minutes", entry.duration / 60)
                            )
                            .foregroundStyle(.cyan)
                            .cornerRadius(4)
                        }
                    }
                    .chartPlotStyle { plotArea in
                        plotArea
                            .padding(.leading, 12)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: 2))
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: geometry.size.height * 0.7)
                    .padding(.horizontal)
                }
            }
            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
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

