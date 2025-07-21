//
//  WeeklyBreakdownReportView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/16/25.
//


import SwiftUI
import DeviceActivity

struct WeeklyBreakdownReportView: View {
    @State private var context = DeviceActivityReport.Context(rawValue: "Weekly Breakdown")
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
            during: Calendar.current.dateInterval(of: .weekOfYear, for: .now)!
        ),
        users: .all,
        devices: DeviceActivityFilter.Devices([.iPhone, .iPad])
    )
    @State private var reloadID = UUID()

    var body: some View {
        DeviceActivityReport(context, filter: filter)
            .id(reloadID)
            .onAppear {
                filter = DeviceActivityFilter(
                    segment: .daily(
                        during: Calendar.current.dateInterval(of: .weekOfYear, for: .now)!
                    ),
                    users: .all,
                    devices: DeviceActivityFilter.Devices([.iPhone, .iPad])
                )
                reloadID = UUID()
            }
    }
}
