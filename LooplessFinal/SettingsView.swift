//
//  SettingsView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/22/25.
//


import SwiftUI
import AVFoundation
import UserNotifications

struct SettingsView: View {
    @State private var hapticsEnabled = true
    @State private var soundEnabled = true
    @State private var notificationStatus = "Checking..."
    @State private var microphoneStatus = "Checking..."

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Privacy")) {
                    HStack {
                        Label("Notifications", systemImage: "bell")
                        Spacer()
                        Text(notificationStatus)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Microphone", systemImage: "mic")
                        Spacer()
                        Text(microphoneStatus)
                            .foregroundColor(.secondary)
                    }

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }

                Section(header: Text("Sound & Haptics")) {
                    Toggle(isOn: $soundEnabled) {
                        Label("Sound Effects", systemImage: "speaker.wave.2")
                    }

                    Toggle(isOn: $hapticsEnabled) {
                        Label("Haptic Feedback", systemImage: "waveform.path")
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                checkNotificationPermission()
                checkMicrophonePermission()
            }
        }
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized: notificationStatus = "Allowed"
                case .denied: notificationStatus = "Denied"
                case .notDetermined: notificationStatus = "Not Asked"
                default: notificationStatus = "Unknown"
                }
            }
        }
    }

    private func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted: microphoneStatus = "Allowed"
        case .denied: microphoneStatus = "Denied"
        case .undetermined: microphoneStatus = "Not Asked"
        @unknown default: microphoneStatus = "Unknown"
        }
    }
}

#Preview {
    SettingsView()
}