import Foundation
import SwiftUI

class ScreenTimeData: ObservableObject {
    static let shared = ScreenTimeData()

    @Published private(set) var dailyTotals: [Date: TimeInterval] = [:]
    private let storageKey = "dailyScreenTimeTotals"

    private init() {
        loadData()
    }

    // MARK: - Persistence

    func loadData() {
        if let data = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: Double] {
            var temp: [Date: TimeInterval] = [:]
            let formatter = Self.dayFormatter
            for (key, value) in data {
                if let date = formatter.date(from: key) {
                    temp[date] = value
                }
            }
            DispatchQueue.main.async {
                self.dailyTotals = temp
            }
        }
    }

    func saveData() {
        var saveDict: [String: Double] = [:]
        let formatter = Self.dayFormatter
        for (date, seconds) in dailyTotals {
            saveDict[formatter.string(from: date)] = seconds
        }
        UserDefaults.standard.set(saveDict, forKey: storageKey)
    }

    static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.current
        return df
    }()

    private func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // MARK: - Daily Logging

    /// Saves elapsed time for today if not already saved
    func recordPreviousDayIfNeeded(currentStopwatchSeconds: TimeInterval) {
        let now = Date()
        let today = startOfDay(for: now)

        // Only save if we don’t already have data for today
        if dailyTotals[today] != nil {
            return
        }

        dailyTotals[today] = currentStopwatchSeconds
        saveData()
        objectWillChange.send()
    }

    /// Saves elapsed time explicitly for a given day (used for previous day at midnight)
    func recordElapsedTime(for date: Date, seconds: TimeInterval) {
        let day = startOfDay(for: date)
        dailyTotals[day] = seconds
        saveData()
        objectWillChange.send()
    }

    // MARK: - Metrics

    var hasEnoughData: Bool {
        dailyTotals.count >= 7
    }

    private func sumScreenTime(from startDate: Date, to endDate: Date) -> TimeInterval {
        dailyTotals
            .filter { $0.key >= startDate && $0.key < endDate }
            .map { $0.value }
            .reduce(0, +)
    }

    private var currentWeekRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let today = Date()
        let startOfWeek = cal.dateInterval(of: .weekOfYear, for: today)?.start ?? cal.startOfDay(for: today)
        let endOfWeek = cal.date(byAdding: .day, value: 7, to: startOfWeek)!
        return (startOfWeek, endOfWeek)
    }

    private var lastWeekRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let currentStart = currentWeekRange.start
        let lastStart = cal.date(byAdding: .day, value: -7, to: currentStart)!
        let lastEnd = currentStart
        return (lastStart, lastEnd)
    }

    var weekOverWeekChange: Double? {
        guard hasEnoughData else { return nil }
        let lastWeekTotal = sumScreenTime(from: lastWeekRange.start, to: lastWeekRange.end)
        let currentWeekTotal = sumScreenTime(from: currentWeekRange.start, to: currentWeekRange.end)
        if lastWeekTotal == 0 { return nil }
        return (currentWeekTotal - lastWeekTotal) / lastWeekTotal * 100
    }

    var weekOverWeekChangeText: String {
        guard let change = weekOverWeekChange else { return "-" }
        return String(format: "%+.1f%%", change)
    }

    var weekOverWeekChangeColor: Color {
        guard let change = weekOverWeekChange else { return .primary }
        return change <= 0 ? .green : .red
    }

    var sevenDayAverage: TimeInterval? {
        guard hasEnoughData else { return nil }
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let total = sumScreenTime(from: sevenDaysAgo, to: Date())
        return total / 7
    }

    var sevenDayAverageText: String {
        guard let avg = sevenDayAverage else { return "-" }
        return formatTimeInterval(avg)
    }

    var todayVsAverage: Double? {
        guard hasEnoughData else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        guard let todayTime = dailyTotals[today], let avg = sevenDayAverage else { return nil }
        return (todayTime - avg) / avg * 100
    }

    var todayVsAverageText: String {
        guard let diff = todayVsAverage else { return "-" }
        if abs(diff) < 5 {
            return "≈ Avg"
        }
        return diff < 0 ? "Better (-\(Int(abs(diff)))%)" : "Worse (+\(Int(diff))%)"
    }

    var todayVsAverageColor: Color {
        guard let diff = todayVsAverage else { return .primary }
        if abs(diff) < 5 {
            return .gray
        }
        return diff < 0 ? .green : .red
    }

    func formatTimeInterval(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        return "\(hours)h \(minutes)m"
    }

    // MARK: - Chart Support

    struct DailyScreenTimePoint: Identifiable {
        let id = UUID()
        let date: Date
        let minutes: Int
    }

    var last7DaysScreenTimeData: [DailyScreenTimePoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find most recent Monday (or today if Monday)
        let weekday = calendar.component(.weekday, from: today)
        // In Gregorian calendar, Sunday=1, Monday=2, ...
        let daysSinceMonday = (weekday + 5) % 7  // how many days since Monday (0 if Monday)
        let startOfWeek = calendar.date(byAdding: .day, value: -daysSinceMonday, to: today)!

        let last7 = (0..<7).map { i in
            let day = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            let dayStart = calendar.startOfDay(for: day)
            let seconds = dailyTotals[dayStart] ?? 0
            return DailyScreenTimePoint(date: dayStart, minutes: Int(seconds / 60))
        }
        return last7
    }
}

