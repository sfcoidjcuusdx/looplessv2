import SwiftUI

struct MainView: View {
    @State private var selectedTab: AppTab = .home
    @State private var loadedTabs: Set<AppTab> = [.home]

    @EnvironmentObject var blockerViewModel: BlockerViewModel
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel
    @EnvironmentObject var dataModel: LooplessDataModel
    @EnvironmentObject var sessionManager: BlockingSessionManager

    @State private var reflectionPopupVisibleForTab: [AppTab: Bool] = [
        .home: false,
        .therapy: false,
        .blocking: false,
        .rewards: false,
        .community: false
    ]

    @AppStorage("hasSeenScheduleTips") private var hasSeenScheduleTips = false
    @State private var showScheduleTips = false

    @Environment(\.scenePhase) private var scenePhase

    let appGroupDefaults = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")

    var body: some View {
        ZStack {
            // Home Tab
            if selectedTab == .home || loadedTabs.contains(.home) {
                NavigationStack {
                    HomeView(
                        selectedTab: $selectedTab,
                        showReflectionPopup: Binding(
                            get: { reflectionPopupVisibleForTab[.home] ?? false },
                            set: { reflectionPopupVisibleForTab[.home] = $0 }
                        )
                    )
                }
                .opacity(selectedTab == .home ? 1 : 0)
            }

            // Therapy Tab
            if selectedTab == .therapy || loadedTabs.contains(.therapy) {
                NavigationStack {
                    TherapyScreenView(
                        selectedTab: $selectedTab,
                        showReflectionPopup: Binding(
                            get: { reflectionPopupVisibleForTab[.therapy] ?? false },
                            set: { reflectionPopupVisibleForTab[.therapy] = $0 }
                        )
                    )
                }
                .opacity(selectedTab == .therapy ? 1 : 0)
            }

            // Blocking Sessions Tab
            if selectedTab == .blocking || loadedTabs.contains(.blocking) {
                NavigationStack {
                    BlockingSessionsView(
                        selectedTab: $selectedTab,
                        showReflectionPopup: Binding(
                            get: { reflectionPopupVisibleForTab[.blocking] ?? false },
                            set: { reflectionPopupVisibleForTab[.blocking] = $0 }
                        )
                    )
                }
                .opacity(selectedTab == .blocking ? 1 : 0)
            }

            // Rewards/Goals Tab
            if selectedTab == .rewards || loadedTabs.contains(.rewards) {
                NavigationStack {
                    GoalsView(
                        selectedTab: $selectedTab,
                        showReflectionPopup: Binding(
                            get: { reflectionPopupVisibleForTab[.rewards] ?? false },
                            set: { reflectionPopupVisibleForTab[.rewards] = $0 }
                        )
                    )
                }
                .opacity(selectedTab == .rewards ? 1 : 0)
            }

            // Community Tab
            if selectedTab == .community || loadedTabs.contains(.community) {
                NavigationStack {
                    CommunityView(
                        showReflectionPopup: Binding(
                            get: { reflectionPopupVisibleForTab[.community] ?? false },
                            set: { reflectionPopupVisibleForTab[.community] = $0 }
                        )
                    )
                }
                .opacity(selectedTab == .community ? 1 : 0)
            }

            // Bottom Tab Bar Overlay
            VStack {
                Spacer()
                TabBar(selectedTab: $selectedTab)
            }
        }
        .onChange(of: selectedTab) { newTab in
            loadedTabs.insert(newTab)
        }
        .accentColor(.cyan)
        .preferredColorScheme(.light)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkReflectionFlag()
            }
        }
        .fullScreenCover(isPresented: $showScheduleTips) {
            ScheduleTipsPopup(show: $showScheduleTips) {
                hasSeenScheduleTips = true
            }
        }
    }

    private func checkReflectionFlag() {
        guard appGroupDefaults?.bool(forKey: "launchIntoReflection") == true else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            reflectionPopupVisibleForTab[selectedTab] = true
            appGroupDefaults?.set(false, forKey: "launchIntoReflection")
        }
    }
}

