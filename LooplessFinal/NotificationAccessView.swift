import SwiftUI
import UserNotifications

struct NotificationAccessView: View {
    var onAuthorized: () -> Void
    @State private var deniedAlert = false
    @State private var isRequesting = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // System icon with standard accent color
                Image(systemName: "bell.badge.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.accentColor)

                // Title
                Text("Enable Notifications")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                // Explanation
                Text("Loopless uses gentle reminders to help you reflect on your screen time and stay focused on your goals.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Request Button
                Button(action: requestNotificationPermission) {
                    Text(isRequesting ? "Requesting..." : "Enable Notifications")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(isRequesting)

                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Notifications Denied", isPresented: $deniedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Notifications are recommended to help you reflect and stay on track.")
            }
        }
    }

    private func requestNotificationPermission() {
        isRequesting = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                isRequesting = false
                if granted {
                    onAuthorized()
                    scheduleSampleReflectionNotification()
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

