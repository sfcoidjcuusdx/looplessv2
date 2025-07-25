import SwiftUI
import DeviceActivity

struct PickupReportView: View {
    @State private var context = DeviceActivityReport.Context(rawValue: "Total Pickups")  // Only this line changed
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
