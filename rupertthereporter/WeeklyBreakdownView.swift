import SwiftUI
import Charts

struct WeeklyBreakdownView: View {
    let usageByDay: [DailyUsage]

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let isCompact = height < 250 || width < 200

            // Adaptive font sizes
            let labelFontSize: CGFloat = isCompact ? 9 : 12
            let valueFontSize: CGFloat = isCompact ? 10 : 12

            VStack(spacing: isCompact ? 4 : 10) {
                // Static title font size
                Text("Usage by Day")
                    .font(.custom("AvenirNext-Medium", size: 14)) // stays fixed
                    .foregroundColor(.white)
                    .padding(.horizontal)

                if usageByDay.isEmpty {
                    Text("No usage recorded.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                } else {
                    Chart {
                        ForEach(usageByDay) { entry in
                            BarMark(
                                x: .value("Minutes", entry.duration / 60),
                                y: .value("Day", isCompact ? shortWeekdayName(for: entry.weekday) : weekdayName(for: entry.weekday))
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color(hue: 0.6, saturation: 1.0, brightness: 0.4)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(4)
                            .annotation(position: .trailing) {
                                Text("\(Int(entry.duration / 60)) min")
                                    .font(.custom("AvenirNext-Regular", size: valueFontSize))
                                    .foregroundColor(.white.opacity(0.8))
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let day = value.as(String.self) {
                                    Text(day)
                                        .font(.custom("AvenirNext-Regular", size: labelFontSize))
                                        .foregroundColor(.white)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom)
                    }
                    .frame(height: height * 0.82)
                    .padding(.horizontal, isCompact ? 6 : 12)
                }
            }
            .padding(isCompact ? 8 : 12)
            .frame(width: width, height: height)
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

    func weekdayName(for number: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.weekdaySymbols[(number - 1) % 7]
    }

    func shortWeekdayName(for number: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.shortWeekdaySymbols[(number - 1) % 7]
    }
}

