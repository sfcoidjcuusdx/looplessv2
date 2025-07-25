import SwiftUI
import UserNotifications

struct ContentView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("screenTimeAuthorized") private var screenTimeAuthorized = false
    @AppStorage("notificationAuthorized") private var notificationAuthorized = false

    @StateObject var looplessDataModel = LooplessDataModel()
    @StateObject var userProfile = UserProfileManager()
    @StateObject var communityVM = CommunityViewModel()

    @State private var showSplash = false

    var body: some View {
        ZStack {
            Group {
                if !showSplash {
                    SplashView(isFinished: $showSplash)
                } else if !onboardingComplete {
                    OnboardingSurveyView {
                        onboardingComplete = true
                    }
                } else if !screenTimeAuthorized {
                    ScreenTimeAccessView {
                        screenTimeAuthorized = true

                    }
                } else if !notificationAuthorized {
                    NotificationAccessView {
                        notificationAuthorized = true
                    }
                } else {
                    MainView()
                        .environmentObject(looplessDataModel)
                        .environmentObject(userProfile)
                        .environmentObject(communityVM)
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("🛑 Notification permission error: \(error.localizedDescription)")
            }
        }
    }
}

