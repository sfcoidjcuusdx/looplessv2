import SwiftUI
import DeviceActivity

struct ExampleView: View {
    @State private var context = DeviceActivityReport.Context(rawValue: "Total Activity")
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
            during: Calendar.current.dateInterval(of: .day, for: .now)!
        ),
        users: .all,
        devices: DeviceActivityFilter.Devices([.iPhone, .iPad]) // ✅ Correct way to initialize
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
                    devices: DeviceActivityFilter.Devices([.iPhone, .iPad]) // ✅ Again, specify type
                )
                reloadID = UUID()
            }
    }
}

