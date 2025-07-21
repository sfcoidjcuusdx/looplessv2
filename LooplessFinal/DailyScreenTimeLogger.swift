//
//  DailyScreenTimeLogger.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/11/25.
//


//
//  DailyScreenTimeLogger.swift
//  Loopless
//
//  Created by Loopless on 7/11/25.
//

import Foundation

struct DailyScreenTimeLogger {
    static let appGroup = "group.crew.LooplessFinal.sharedData"

    /// Save screen time data for a given date.
    static func saveScreenTime(for date: Date, duration: TimeInterval) {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll

        let formatted = formatter.string(from: duration) ?? "0s"
        let dateKey = dateKeyString(for: date)

        if let defaults = UserDefaults(suiteName: appGroup) {
            defaults.set(duration, forKey: "screenTimeSeconds-\(dateKey)")
            defaults.set(formatted, forKey: "screenTimeFormatted-\(dateKey)")
        }
    }

    /// Load today's screen time data (duration + formatted).
    static func loadTodayScreenTime() -> (seconds: TimeInterval, formatted: String) {
        let todayKey = dateKeyString(for: Date())
        let defaults = UserDefaults(suiteName: appGroup)
        let seconds = defaults?.double(forKey: "screenTimeSeconds-\(todayKey)") ?? 0
        let formatted = defaults?.string(forKey: "screenTimeFormatted-\(todayKey)") ?? "0s"
        return (seconds, formatted)
    }

    /// Load screen time data for a specific date.
    static func loadScreenTime(for date: Date) -> (seconds: TimeInterval, formatted: String) {
        let dateKey = dateKeyString(for: date)
        let defaults = UserDefaults(suiteName: appGroup)
        let seconds = defaults?.double(forKey: "screenTimeSeconds-\(dateKey)") ?? 0
        let formatted = defaults?.string(forKey: "screenTimeFormatted-\(dateKey)") ?? "0s"
        return (seconds, formatted)
    }

    /// Helper to format a Date into a short key (e.g., "7/11/25")
    static private func dateKeyString(for date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
    }
}
