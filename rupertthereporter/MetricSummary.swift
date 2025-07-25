//
//  MetricSummary.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/16/25.
//

import DeviceActivity
import Foundation
import _DeviceActivity_SwiftUI

struct MetricSummary: Codable, Hashable {
    let momentumIndex: Double      // Trend of screen time within this week
    let usageStability: Double     // Average screen time over last 7 days
    let impulseControl: Double     // Today's screen time vs. weekly average (positive = good)
}

extension DeviceActivityReport.Context {
    static let metricSummary = Self("Metric Summary")
}

struct MetricSummaryReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .metricSummary
    let content: (MetricSummary) -> MetricSummaryView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> MetricSummary {
        var dayTotals: [Date: TimeInterval] = [:]
        let calendar = Calendar.current

        for await activityData in data {
            for await segment in activityData.activitySegments {
                let day = calendar.startOfDay(for: segment.dateInterval.start)
                dayTotals[day, default: 0] += segment.totalActivityDuration
            }
        }

        let sortedDays = dayTotals.keys.sorted()
        let last7Days = Array(sortedDays.suffix(7))
        let last7Values = last7Days.map { dayTotals[$0]! }

        let usageStability = last7Values.reduce(0, +) / Double(max(last7Values.count, 1))

        let today = calendar.startOfDay(for: Date())
        let todayValue = dayTotals[today] ?? 0

        // Positive impulseControl = better control (less usage today vs weekly avg)
        let impulseControl = usageStability > 0
            ? (1 - todayValue / usageStability)
            : 0

        // MARK: - New Momentum Index: screen time trend this week (correlation with weekday)
        let weekdayValues: [(Int, Double)] = last7Days.map {
            let weekday = calendar.component(.weekday, from: $0) // Sunday = 1 ... Saturday = 7
            return (weekday, dayTotals[$0] ?? 0)
        }

        let weekdayXs = weekdayValues.map { Double($0.0) }
        let screenTimeYs = weekdayValues.map { $0.1 }

        let momentumIndex = correlation(xs: weekdayXs, ys: screenTimeYs)

        return MetricSummary(
            momentumIndex: momentumIndex,
            usageStability: usageStability,
            impulseControl: impulseControl
        )
    }

    /// Pearson correlation coefficient
    private func correlation(xs: [Double], ys: [Double]) -> Double {
        guard xs.count == ys.count, xs.count >= 2 else { return 0 }

        let n = Double(xs.count)
        let sumX = xs.reduce(0, +)
        let sumY = ys.reduce(0, +)
        let sumXY = zip(xs, ys).map(*).reduce(0, +)
        let sumX2 = xs.map { $0 * $0 }.reduce(0, +)
        let sumY2 = ys.map { $0 * $0 }.reduce(0, +)

        let numerator = (n * sumXY) - (sumX * sumY)
        let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))

        guard denominator != 0 else { return 0 }

        return numerator / denominator
    }
}

