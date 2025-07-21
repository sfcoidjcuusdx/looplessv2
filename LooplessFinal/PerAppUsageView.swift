//
//  PerAppUsageView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/16/25.
//


import SwiftUI
import DeviceActivity

struct PerAppUsageView: View {
    @State private var context = DeviceActivityReport.Context(rawValue: "Per App Usage")
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
            during: Calendar.current.dateInterval(of: .day, for: .now)!
        ),
        users: .all,
        devices: .init([.iPhone, .iPad])
    )
    @State private var reloadID = UUID()
    
    var body: some View {
        VStack {
            // Header with title
            Text("App Usage Breakdown")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
            
            // The actual report
            DeviceActivityReport(context, filter: filter)
                .id(reloadID)
        }
        .onAppear {
            refreshData()
        }
        .refreshable {
            refreshData()
        }
    }
    
    private func refreshData() {
        filter = DeviceActivityFilter(
            segment: .daily(
                during: Calendar.current.dateInterval(of: .day, for: .now)!
            ),
            users: .all,
            devices: .init([.iPhone, .iPad])
        )
        reloadID = UUID()
    }
}

// Preview provider
struct PerAppUsageView_Previews: PreviewProvider {
    static var previews: some View {
        PerAppUsageView()
    }
}