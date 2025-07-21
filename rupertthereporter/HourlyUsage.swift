//
//  HourlyUsage.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/16/25.
//


//
//  AppBreakdownReport.swift
//  broughton
//
//  Created by rafiq kutty on 7/16/25.
//

import DeviceActivity
import SwiftUI
import Charts

// MARK: - Define your custom report context
extension DeviceActivityReport.Context {
    static let appBreakdown = Self("App Breakdown")
}

// MARK: - Hourly usage model
struct HourlyUsage: Identifiable {
    let id = UUID()
    let hour: Int
    let duration: TimeInterval
}

// MARK: - Report scene that outputs data for charting
struct AppBreakdownReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .appBreakdown
    let content: ([HourlyUsage]) -> AppBreakdownView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [HourlyUsage] {
        var hourlyMap: [Int: TimeInterval] = [:]

        for await activityData in data {
            for await segment in activityData.activitySegments {
                let startHour = Calendar.current.component(.hour, from: segment.dateInterval.start)
                hourlyMap[startHour, default: 0] += segment.totalActivityDuration
            }
        }

        let sortedHourlyData = hourlyMap
            .sorted { $0.key < $1.key }
            .map { HourlyUsage(hour: $0.key, duration: $0.value) }

        return sortedHourlyData
    }
}

