//
//  ReflectionNotificationManager.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/15/25.
//


import Foundation
import UserNotifications

class ReflectionNotificationManager: ObservableObject {
    static let shared = ReflectionNotificationManager()
    private let defaults = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")

    private init() {}

    func checkAndSendNotification() {
        guard let trigger = defaults?.bool(forKey: "TriggerReflectionNotification"), trigger else { return }
        scheduleReflectionNotification()
        defaults?.set(false, forKey: "TriggerReflectionNotification")
    }

    private func scheduleReflectionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Ready to Reflect?"
        content.body = "Tap to return to Loopless and reflect on your screen time."
        content.sound = .default
        content.userInfo = ["action": "openReflection"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "LooplessReflectionPrompt", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reflection notification: \(error)")
            }
        }
    }
}
