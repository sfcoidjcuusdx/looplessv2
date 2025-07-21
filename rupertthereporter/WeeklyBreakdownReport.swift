//
//  WeeklyBreakdownReport.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/16/25.
//

import Foundation
import DeviceActivity
import _DeviceActivity_SwiftUI

struct DailyUsage: Identifiable {
    let id = UUID()
    let weekday: Int // 1 = Sunday ... 7 = Saturday
    let duration: TimeInterval
}

extension DeviceActivityReport.Context {
    static let weeklyBreakdown = Self("Weekly Breakdown")
}

struct WeeklyBreakdownReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .weeklyBreakdown
    let content: ([DailyUsage]) -> WeeklyBreakdownView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [DailyUsage] {
        var dailyMap: [Int: TimeInterval] = [:]

        for await activityData in data {
            for await segment in activityData.activitySegments {
                let weekday = Calendar.current.component(.weekday, from: segment.dateInterval.start)
                dailyMap[weekday, default: 0] += segment.totalActivityDuration
            }
        }

        return dailyMap
            .sorted { $0.key < $1.key }
            .map { DailyUsage(weekday: $0.key, duration: $0.value) }
    }
}
