//
//  MainView.swift
//  LooplessFinal
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: AppTab = .home

    @StateObject private var blockerViewModel = BlockerViewModel()
    @StateObject private var scheduleViewModel = ScheduleViewModel()
    @EnvironmentObject var dataModel: LooplessDataModel
    @EnvironmentObject var sessionManager: BlockingSessionManager

    // ✅ Pre-fill all tabs to ensure proper reactivity
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
    @State private var showReflectionPopup = false

    let appGroupDefaults = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                mainContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                BottomNavigationView(selectedTab: $selectedTab)
            }
            .background(Color.black)
            .preferredColorScheme(.dark)
        }
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

    @ViewBuilder
    private var mainContent: some View {
        switch selectedTab {
        case .home:
            NavigationStack {
                HomeView(
                    selectedTab: $selectedTab,
                    showReflectionPopup: Binding(
                        get: { reflectionPopupVisibleForTab[.home] ?? false },
                        set: { reflectionPopupVisibleForTab[.home] = $0 }
                    )
                ).environmentObject(dataModel)
            }

        case .therapy:
            NavigationStack {
                TherapyScreenView(
                    selectedTab: $selectedTab,
                    showReflectionPopup: Binding(
                        get: { reflectionPopupVisibleForTab[.therapy] ?? false },
                        set: { reflectionPopupVisibleForTab[.therapy] = $0 }
                    )
                )
            }

        case .blocking:
            NavigationStack {
                BlockingSessionsView(
                    selectedTab: $selectedTab,
                    showReflectionPopup: Binding(
                        get: { reflectionPopupVisibleForTab[.blocking] ?? false },
                        set: { reflectionPopupVisibleForTab[.blocking] = $0 }
                    )
                )
                .environmentObject(dataModel)
                .environmentObject(sessionManager)
            }

        case .rewards:
            NavigationStack {
                GoalsView(
                    viewModel: blockerViewModel,
                    scheduleViewModel: scheduleViewModel,
                    selectedTab: $selectedTab,
                    showReflectionPopup: Binding(
                        get: { reflectionPopupVisibleForTab[.rewards] ?? false },
                        set: { reflectionPopupVisibleForTab[.rewards] = $0 }
                    )
                )
            }

        case .community:
            NavigationStack {
                CommunityView(
                    showReflectionPopup: Binding(
                        get: { reflectionPopupVisibleForTab[.community] ?? false },
                        set: { reflectionPopupVisibleForTab[.community] = $0 }
                    )
                )
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

