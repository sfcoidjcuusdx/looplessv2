import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings

struct AppLimitPickerView: View {
    @EnvironmentObject var looplessDataModel: LooplessDataModel
    @State private var isPickerPresented = false
    @State private var limitInputs: [ApplicationToken: String] = [:]
    @State private var saveMessage: String?

    @FocusState private var focusedToken: ApplicationToken?

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Daily App Time Limits")
                .font(.title2)
                .bold()

            Button("Pick Apps to Set Limits") {
                isPickerPresented = true
            }
            .familyActivityPicker(
                isPresented: $isPickerPresented,
                selection: $looplessDataModel.timeLimitSelection
            )

            if looplessDataModel.timeLimitSelection.applicationTokens.isEmpty {
                Text("No apps selected.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(looplessDataModel.timeLimitSelection.applicationTokens), id: \.self) { token in
                            VStack(alignment: .leading, spacing: 8) {
                                Label(token)
                                    .font(.headline)

                                TextField("Limit in minutes", text: Binding(
                                    get: { limitInputs[token] ?? "" },
                                    set: { limitInputs[token] = $0 }
                                ))
                                .keyboardType(.numberPad)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .focused($focusedToken, equals: token)

                                Button("Save Limit") {
                                    saveLimit(for: token)
                                    focusedToken = nil
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)

                                if let encodedToken = try? PropertyListEncoder().encode(token),
                                   let limit = looplessDataModel.appLimits.first(where: { $0.tokenData == encodedToken }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Limit: \(limit.dailyLimitMinutes) minutes")
                                                .font(.subheadline)
                                            if let date = limit.dateSet {
                                                Text("Set on: \(formatted(date))")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }

                                        Spacer()

                                        Button(action: {
                                            cancelLimit(for: token)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(10)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                    }
                    .padding(.top)
                }
            }

            if let saveMessage = saveMessage {
                Text(saveMessage)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            looplessDataModel.loadAppLimits()
            looplessDataModel.loadTimeLimitSelection()
            preloadLimitInputs()
        }
    }

    private func saveLimit(for token: ApplicationToken) {
        guard let limitStr = limitInputs[token], let minutes = Int(limitStr), minutes > 0 else {
            saveMessage = "Please enter a valid number of minutes."
            return
        }

        do {
            let encoded = try PropertyListEncoder().encode(token)

            if let index = looplessDataModel.appLimits.firstIndex(where: {
                $0.tokenData == encoded
            }) {
                looplessDataModel.appLimits[index].dailyLimitMinutes = minutes
                looplessDataModel.appLimits[index].dateSet = Date()
            } else {
                let newLimit = AppTimeLimit(tokenData: encoded, dailyLimitMinutes: minutes, dateSet: Date())
                looplessDataModel.appLimits.append(newLimit)
            }

            looplessDataModel.saveAppLimits()
            looplessDataModel.saveTimeLimitSelection()

            DeviceActivityCenter().stopMonitoring()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                looplessDataModel.startMonitoringLimits()
            }


            preloadLimitInputs()
            saveMessage = "✅ Limit saved and monitoring started."
        } catch {
            saveMessage = "❌ Failed to save limit: \(error.localizedDescription)"
        }
    }

    private func cancelLimit(for token: ApplicationToken) {
        do {
            let encoded = try PropertyListEncoder().encode(token)
            looplessDataModel.appLimits.removeAll { $0.tokenData == encoded }
            looplessDataModel.saveAppLimits()

            DeviceActivityCenter().stopMonitoring()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                looplessDataModel.startMonitoringLimits()
            }
            preloadLimitInputs()
            saveMessage = "🗑️ Limit removed."
        } catch {
            saveMessage = "❌ Failed to cancel limit."
        }
    }

    private func preloadLimitInputs() {
        limitInputs.removeAll()
        for limit in looplessDataModel.appLimits {
            if let token = limit.token {
                limitInputs[token] = "\(limit.dailyLimitMinutes)"
            }
        }
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

