//
//  rupertthereporter.swift
//  rupertthereporter
//
//  Created by rafiq kutty on 7/10/25.
//

import DeviceActivity
import SwiftUI

@main
struct rupertthereporter: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Text-based screen time report
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }

        // Chart-based app usage report
        AppBreakdownReport { usageByHour in
            AppBreakdownView(usageByHour: usageByHour)
        }

        // Weekly usage breakdown
        WeeklyBreakdownReport { summary in
            WeeklyBreakdownView(usageByDay: summary)
        }

        // Mind Presence report
        MetricSummaryReport { summary in
            MetricSummaryView(summary: summary)
        }
    }
}
