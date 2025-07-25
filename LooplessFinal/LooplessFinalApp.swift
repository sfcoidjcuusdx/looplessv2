import SwiftUI
import SwiftData

@main
struct LooplessFinalApp: App {
    @StateObject private var dataModel = LooplessDataModel()
    @StateObject private var sessionManager = BlockingSessionManager()
    @StateObject private var rewardsEvaluator = RewardsEvaluator()
    @StateObject private var blockerViewModel = BlockerViewModel()
    @StateObject private var scheduleViewModel = ScheduleViewModel()


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataModel)
                .environmentObject(sessionManager)
                .environmentObject(rewardsEvaluator)
                .environmentObject(blockerViewModel)         // ✅ NEW
                    .environmentObject(scheduleViewModel) 
                .onAppear {
                    // 🔗 Link ViewModels
                    dataModel.sessionManager = sessionManager
                    sessionManager.rewardsEvaluator = rewardsEvaluator

                    // 🗂️ Load limits from storage
                    dataModel.loadAppLimits()

                    // ⏰ Start monitoring time-based limits
                    dataModel.startMonitoringLimits()

                    // 🧠 Initial shielding for app blocks (some might be wiped by DeviceActivityMonitor briefly)
                    dataModel.applyAppShielding()

                    // ⏳ Delay to reapply preset shields *after* DeviceActivityMonitor initializes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dataModel.scheduleTodayBlockingEvents()
                        dataModel.evaluateBlocking()
                        dataModel.reapplyTimeLimitShieldsIfNeeded()
                    }

                    // 🔁 Respond to app foreground entry
                    NotificationCenter.default.addObserver(
                        forName: UIApplication.willEnterForegroundNotification,
                        object: nil,
                        queue: .main
                    ) { _ in
                        print("🔄 App entered foreground – reapplying blocking logic")

                        dataModel.startMonitoringLimits()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dataModel.scheduleTodayBlockingEvents()
                            dataModel.evaluateBlocking()
                            dataModel.reapplyTimeLimitShieldsIfNeeded()
                        }
                    }
                }
                .preferredColorScheme(.light)
        }
        .modelContainer(Self.createModelContainer())
    }

    // MARK: - Model Container Helper
    static func createModelContainer() -> ModelContainer {
        let schema = Schema([Item.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

