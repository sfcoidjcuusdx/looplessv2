import SwiftUI
import Charts

struct WeeklyBreakdownView: View {
    let usageByDay: [DailyUsage]

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let isCompact = height < 250 || width < 200

            let labelFont: Font = isCompact ? .caption2 : .caption
            let valueFont: Font = isCompact ? .caption : .footnote

            VStack(alignment: .leading, spacing: isCompact ? 4 : 10) {
                Text("Usage by Day")
                    .font(.headline)
                    .padding(.horizontal)

                if usageByDay.isEmpty {
                    Text("No usage recorded.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    Chart {
                        ForEach(usageByDay) { entry in
                            BarMark(
                                x: .value("Minutes", entry.duration / 60),
                                y: .value("Day", isCompact ? shortWeekdayName(for: entry.weekday) : weekdayName(for: entry.weekday))
                            )
                            .foregroundStyle(.cyan)
                            .annotation(position: .trailing) {
                                Text("\(Int(entry.duration / 60)) min")
                                    .font(valueFont)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let day = value.as(String.self) {
                                    Text(day)
                                        .font(labelFont)
                                        .foregroundColor(.primary)
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
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

