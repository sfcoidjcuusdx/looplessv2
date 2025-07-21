import ManagedSettings
import UserNotifications

class ShieldActionExtension: ShieldActionDelegate {
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Set launch flag in App Group and schedule a reflection notification
            sendReflectionNotification()
            
            // Delay briefly to allow notification scheduling
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completionHandler(.close)
            }
        case .secondaryButtonPressed:
            completionHandler(.defer)
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }
    
    /// Sends a local notification and flags app to open with a reflection popup
    private func sendReflectionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Take a Deep Breath 🌿"
        content.body = "You're doing great. Let's take a moment to reflect in Loopless."
        content.sound = .default
        content.userInfo = ["openReflection": true]

        // ✅ Set shared App Group flag so the main app knows to show the popup
        let defaults = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData") // ⚠️ Replace with your real App Group ID
        defaults?.set(true, forKey: "launchIntoReflection")

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🚨 Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Reflection notification scheduled.")
            }
        }
    }
}

