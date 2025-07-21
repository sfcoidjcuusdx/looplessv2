//
//  TotalActivityReport.swift
//  rupertthereporter
//
//  Created by rafiq kutty on 7/10/25.
//

import DeviceActivity
import SwiftUI

// MARK: - Report Contexts

extension DeviceActivityReport.Context {
    /// Context for showing total screen time in a custom view
    static let totalActivity = Self("Total Activity")


    /// Context for showing per-app usage in default Apple view
}

// MARK: - Total Screen Time Report (Custom View)

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: (String) -> TotalActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll

        let totalActivityDuration = await data
            .flatMap { $0.activitySegments }
            .reduce(0) { $0 + $1.totalActivityDuration }

        let formatted = formatter.string(from: totalActivityDuration) ?? "No activity data"

        // Save raw duration (seconds) with today's date
        let dateKey = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)

        if let defaults = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData") {
            defaults.set(totalActivityDuration, forKey: "screenTimeSeconds-\(dateKey)")
            defaults.set(formatted, forKey: "screenTimeFormatted-\(dateKey)")
        }

        return formatted
    }
}





