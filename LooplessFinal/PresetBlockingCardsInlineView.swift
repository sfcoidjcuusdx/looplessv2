import SwiftUI
import FamilyControls

struct PresetBlockingCardsInlineView: View {
    @EnvironmentObject var dataModel: LooplessDataModel
    @EnvironmentObject var sessionManager: BlockingSessionManager

    @State private var showConfirmation: Bool = false
    @State private var appliedPresetName: String = ""
    @State private var usedPresets: Set<String> = []
    @State private var isApplyingPreset: Bool = false

    private let presetCooldownDays: Int = 7
    private let userDefaultsKey = "UsedPresetTimestamps"

    private let presets: [BlockingPreset] = [
        BlockingPreset(
            name: "Work Mode",
            icon: "briefcase.fill",
            description: "Focus from 9 AM to 5 PM on weekdays",
            days: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
            startTime: DateComponents(hour: 9, minute: 0),
            endTime: DateComponents(hour: 17, minute: 0)
        ),
        BlockingPreset(
            name: "Sleep Shield",
            icon: "moon.fill",
            description: "Unwind and rest from 10 PM to 6 AM",
            days: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
            startTime: DateComponents(hour: 22, minute: 0),
            endTime: DateComponents(hour: 6, minute: 0)
        ),
        BlockingPreset(
            name: "Weekend Refresh",
            icon: "sparkles",
            description: "Screen-free from 9 AM to 12 PM on weekends",
            days: ["Saturday", "Sunday"],
            startTime: DateComponents(hour: 9, minute: 0),
            endTime: DateComponents(hour: 12, minute: 0)
        ),
        BlockingPreset(
                name: "TestERS",
                icon: "clock.fill",
                description: "Block apps for 1 hour starting at 5 PM today",
                days: [DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]],
                startTime: DateComponents(hour: 18, minute: 0),
                endTime: DateComponents(hour: 19, minute: 0)
            )
    ]

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Blocking Modes")
                    .font(.title3.bold())
                    .padding(.horizontal)

                ForEach(presets, id: \.name) { preset in
                    if !usedPresets.contains(preset.name) {
                        Button(action: {
                            applyPreset(preset)
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: preset.icon)
                                    .font(.title2)
                                    .foregroundColor(.cyan)
                                    .padding(.top, 4)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(preset.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(preset.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Text("\(preset.startTime.formatHM()) – \(preset.endTime.formatHM())")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .disabled(isApplyingPreset)
                        .opacity(isApplyingPreset ? 0.5 : 1)
                        .animation(.easeOut(duration: 0.3), value: isApplyingPreset)
                    }
                }
            }
            .padding(.top, 12)

            // Toast Notification
            if showConfirmation {
                VStack {
                    Spacer()
                    Text("✅ \(appliedPresetName) applied!")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.thinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .padding(.bottom, 60)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(1)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showConfirmation)
            }
        }
        .onAppear {
            cleanupOldPresets()
        }
    }

    func applyPreset(_ preset: BlockingPreset) {
        isApplyingPreset = true
        appliedPresetName = preset.name
        
        // Show toast immediately
        withAnimation(.spring()) {
            showConfirmation = true
        }
        
        // Hide the card with fade animation
        withAnimation(.easeOut(duration: 0.3)) {
            usedPresets.insert(preset.name)
        }

        let calendar = Calendar.current
        let now = Date()
        var matchedActive = false

        for day in preset.days {
            var start = dateFor(dayOfWeek: day, time: preset.startTime)
            var end = dateFor(dayOfWeek: day, time: preset.endTime)

            if end <= start {
                end = calendar.date(byAdding: .day, value: 1, to: end)!
            }

            if now >= start && now <= end && !matchedActive {
                sessionManager.addSession(
                    name: preset.name,
                    selection: dataModel.selection,
                    start: start,
                    end: end,
                    dayOfWeek: day
                )
                matchedActive = true

                // ✅ Also add to schedule so evaluateBlocking sees it
                dataModel.scheduleViewModel.addBlockingEvent(
                    name: preset.name,
                    for: day,
                    start: preset.startTime,
                    end: preset.endTime
                )

                print("✅ Applied ACTIVE preset session: \(preset.name) on \(day) \(start) → \(end)")

                // ✅ Now evaluate blocking
                dataModel.evaluateBlocking()
            }



            // Schedule future sessions
            if start > now {
                dataModel.scheduleViewModel.addBlockingEvent(
                    name: preset.name,
                    for: day,
                    start: preset.startTime,
                    end: preset.endTime
                )
                print("📅 Scheduled future preset session: \(preset.name) on \(day)")
            }
        }

        // Save to used presets
        saveUsedPreset(preset.name)

        // Re-evaluate blocking and UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dataModel.evaluateBlocking()
            dataModel.scheduleTodayBlockingEvents()
            sessionManager.loadTodaySessions(from: dataModel.scheduleViewModel, selection: dataModel.selection)
            
            // Reset applying state
            isApplyingPreset = false
        }

        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeIn) {
                showConfirmation = false
            }
        }
    }

    func saveUsedPreset(_ name: String) {
        var stored = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: Date] ?? [:]
        stored[name] = Date()
        UserDefaults.standard.setValue(stored, forKey: userDefaultsKey)
    }

    func cleanupOldPresets() {
        let now = Date()
        var stored = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: Date] ?? [:]
        stored = stored.filter { key, date in
            guard let date = date as? Date else { return false }
            return Calendar.current.dateComponents([.day], from: date, to: now).day ?? 0 < presetCooldownDays
        }
        usedPresets = Set(stored.keys)
        UserDefaults.standard.setValue(stored, forKey: userDefaultsKey)
    }
    
    private func dateFor(dayOfWeek: String, time: DateComponents) -> Date {
        var components = time
        let calendar = Calendar.current
        let weekdaySymbols = calendar.weekdaySymbols
        let today = Date()
        let todayWeekdayIndex = calendar.component(.weekday, from: today) - 1
        let targetIndex = weekdaySymbols.firstIndex(of: dayOfWeek)!
        
        let dayOffset = (targetIndex - todayWeekdayIndex + 7) % 7
        let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        return calendar.date(from: dateComponents)!
    }
}

// MARK: - Supporting Models

struct BlockingPreset {
    let name: String
    let icon: String
    let description: String
    let days: [String]
    let startTime: DateComponents
    let endTime: DateComponents
}

extension DateComponents {
    func formatHM() -> String {
        let calendar = Calendar.current
        guard let date = calendar.date(from: self) else { return "" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
