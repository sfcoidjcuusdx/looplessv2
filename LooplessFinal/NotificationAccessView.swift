//
//  NotificationAccessView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/15/25.
//


import SwiftUI
import UserNotifications

struct NotificationAccessView: View {
    var onAuthorized: () -> Void
    @State private var deniedAlert = false
    @State private var isRequesting = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [.black, .gray.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Icon
                Image(systemName: "bell.badge.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(radius: 10)

                // Title
                Text("Enable Notifications")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                    )

                // Explanation
                Text("Loopless uses gentle reminders to help you reflect on your screen time and stay focused on your goals. Notifications are a key part of your recovery journey.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)

                // Request Button
                Button(action: requestNotificationPermission) {
                    Text(isRequesting ? "Requesting..." : "Enable Notifications")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                }
                .disabled(isRequesting)

                Spacer()
            }
            .padding()
        }
        .alert("Notifications Denied", isPresented: $deniedAlert) {
            Button("OK") {}
        } message: {
            Text("Notifications are recommended to help you reflect and stay on track.")
        }
        .preferredColorScheme(.dark)
    }

    private func requestNotificationPermission() {
        isRequesting = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                isRequesting = false
                if granted {
                    onAuthorized()
                    scheduleSampleReflectionNotification() // Optional test notification
                } else {
                    deniedAlert = true
                }
            }
        }
    }

    private func scheduleSampleReflectionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Loopless Reflection"
        content.body = "How did your screen time feel today?"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "reflectionReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
