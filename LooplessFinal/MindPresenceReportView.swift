//
//  MindPresenceReportView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/21/25.
//


import SwiftUI
import DeviceActivity

struct MindPresenceReportView: View {
    @State private var context = DeviceActivityReport.Context("Mind Presence")
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
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
                // Refresh the filter to ensure report loads fresh
                filter = DeviceActivityFilter(
                    segment: .daily(
                        during: Calendar.current.dateInterval(of: .day, for: .now)!
                    ),
                    users: .all,
                    devices: DeviceActivityFilter.Devices([.iPhone, .iPad])
                )
                reloadID = UUID()
            }
    }
}
