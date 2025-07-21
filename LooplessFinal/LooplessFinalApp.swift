//
//  LooplessFinalApp.swift
//  LooplessFinal
//

import SwiftUI
import SwiftData

@main
struct LooplessFinalApp: App {
    @StateObject private var dataModel = LooplessDataModel()
    @StateObject private var sessionManager = BlockingSessionManager()
    @StateObject private var rewardsEvaluator = RewardsEvaluator()

    // Shared model container for SwiftData persistence
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataModel)
                .environmentObject(sessionManager)
                .environmentObject(rewardsEvaluator)
                .onAppear {
                    // Link dataModel to sessionManager
                    dataModel.sessionManager = sessionManager

                    // Inject RewardsEvaluator into sessionManager (⚠️ needed for unlocking rewards)
                    sessionManager.rewardsEvaluator = rewardsEvaluator

                    // Apply any saved app blocking on launch
                    dataModel.applyAppShielding()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

