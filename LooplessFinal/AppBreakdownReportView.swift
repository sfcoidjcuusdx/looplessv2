//
//  AppBreakdownReportView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/16/25.
//


//
//  AppBreakdownReportView.swift
//  pappy
//
//  Created by rafiq kutty on 7/16/25.
//

import Foundation
import SwiftUI
import DeviceActivity

struct AppBreakdownReportView: View {
    @State private var context = DeviceActivityReport.Context(rawValue: "App Breakdown")
    @State private var filter = DeviceActivityFilter(
        segment: .hourly(
            during: Calendar.current.dateInterval(of: .day, for: .now)!
        ),
        users: .all,
        devices: DeviceActivityFilter.Devices([.iPhone, .iPad])
    )
    @State private var reloadID = UUID()

    var body: some View {
        DeviceActivityReport(context, filter: filter)
            .id(reloadID)
            .onAppear {
                // Refresh filter and reload ID to re-render report
                filter = DeviceActivityFilter(
                    segment: .hourly(
                        during: Calendar.current.dateInterval(of: .day, for: .now)!
                    ),
                    users: .all,
                    devices: DeviceActivityFilter.Devices([.iPhone, .iPad])
                )
                reloadID = UUID()
            }
    }
}

