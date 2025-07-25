import SwiftUI
import FamilyControls
import ManagedSettings

struct AppLimitListInlineView: View {
    @EnvironmentObject var dataModel: LooplessDataModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Time Limits")
                .font(.title3.bold())
                .padding(.horizontal)

            if dataModel.appLimits.isEmpty {
                Text("No daily time limits set.")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .italic()
                    .padding(.horizontal)
            } else {
                ForEach(dataModel.appLimits) { limit in
                    if let token = limit.token {
                        AppLimitCardInline(limit: limit, token: token) {
                            cancelLimit(for: token)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.top)
    }

    private func cancelLimit(for token: ApplicationToken) {
        do {
            let encoded = try PropertyListEncoder().encode(token)

            dataModel.appLimits.removeAll { $0.tokenData == encoded }

            dataModel.timeLimitSelection.applicationTokens.remove(token)

            let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("group.crew.LooplessFinal.sharedData"))
            var current = store.shield.applications ?? Set()
            current.remove(token)
            store.shield.applications = current.isEmpty ? nil : current

            let timestampsKey = "LimitHitTimestamps"
            let tokenID = encoded.base64EncodedString()
            if var dict = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.dictionary(forKey: timestampsKey) as? [String: Date] {
                dict.removeValue(forKey: tokenID)
                UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.set(dict, forKey: timestampsKey)
                print("🗑️ Removed timestamp for \(tokenID.prefix(8))")
            }

            dataModel.saveAppLimits()
            dataModel.saveTimeLimitSelection()

            dataModel.startMonitoringLimits()

            print("✅ Time limit for app removed successfully.")
        } catch {
            print("❌ Failed to cancel limit: \(error.localizedDescription)")
        }
    }
}

struct AppLimitCardInline: View {
    let limit: AppTimeLimit
    let token: ApplicationToken
    let onCancel: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
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
                    .font(.title3)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

