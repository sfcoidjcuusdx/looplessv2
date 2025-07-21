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
        // Text-based report
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }

        // Chart-based report using hourly usage
        AppBreakdownReport { usageByHour in
            AppBreakdownView(usageByHour: usageByHour)
        }
        
        WeeklyBreakdownReport { summary in
                    WeeklyBreakdownView(usageByDay: summary)
                }
        
        MetricSummaryReport { summary in
            MetricSummaryView(summary: summary)
        }

    }
}
