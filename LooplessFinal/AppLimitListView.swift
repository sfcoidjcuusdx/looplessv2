//
//  AppLimitListView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/23/25.
//


import SwiftUI
import ManagedSettings
import FamilyControls

struct AppLimitListView: View {
    @EnvironmentObject var looplessDataModel: LooplessDataModel

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                if looplessDataModel.appLimits.isEmpty {
                    Text("No active time limits.")
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(looplessDataModel.appLimits) { limit in
                                if let token = limit.token {
                                    AppLimitCard(limit: limit, token: token) {
                                        cancelLimit(for: token)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Your App Timers")
        }
    }

    private func cancelLimit(for token: ApplicationToken) {
        do {
            let encoded = try PropertyListEncoder().encode(token)
            looplessDataModel.appLimits.removeAll { $0.tokenData == encoded }
            looplessDataModel.saveAppLimits()
            looplessDataModel.startMonitoringLimits()
        } catch {
            print("❌ Failed to cancel limit.")
        }
    }
}

struct AppLimitCard: View {
    let limit: AppTimeLimit
    let token: ApplicationToken
    let onCancel: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Label(token)
                    .font(.headline)

                Text("Limit: \(limit.dailyLimitMinutes) minutes")
                    .font(.subheadline)

                if let date = limit.dateSet {
                    Text("Set on: \(formatted(date))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 1)
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
