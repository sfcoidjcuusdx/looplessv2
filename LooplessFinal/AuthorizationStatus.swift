//
//  LooplessDataModel.swift
//  LooplessFinal
//

import Foundation
import SwiftUI
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity

enum AuthorizationStatus: String, Codable {
    case notDetermined
    case approved
    case denied
}

struct MoodEntry: Identifiable {
    let id = UUID()
    let date: Date
    let moodLevel: Int
}

class LooplessDataModel: ObservableObject {
    @Published var blockedAppLabels: [String] = []
    @Published var appUsage: [String: Int] = [:]
    @Published var hourlyUsage: [Int: Int] = (0..<24).reduce(into: [:]) { $0[$1] = 0 }
    @Published var weeklyUsage: [String: Double] = [:]
    @Published var moodEntries: [MoodEntry] = []
    @Published var notificationsPerHour: [Int] = Array(repeating: 0, count: 24)
    @Published var selection = FamilyActivitySelection()
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var scheduleViewModel = ScheduleViewModel()
    @Published var sessionManager: BlockingSessionManager? = nil
    @Published var cancelledEvents: Set<String> = []
    private var lastActiveSessionKeys: Set<String> = []
    @Published var appLimits: [AppTimeLimit] = []
    @Published var timeLimitSelection = FamilyActivitySelection()



    private var unblockTimer: Timer?
    private var blockEnd: Date?

    private let savedSelectionKey = "SavedFamilySelection"
    private let labelKey = "BlockedAppLabels"
    private let cancelledEventsKey = "CancelledBlockingEvents"

    private let timeLimitStore = ManagedSettingsStore(named: ManagedSettingsStore.Name("group.crew.LooplessFinal.sharedData"))
    private let presetStore = ManagedSettingsStore(named: ManagedSettingsStore.Name("LooplessPresetShielding"))


    init() {
        loadAppLimits()                  // ✅ Moved to top
        loadSavedLabels()
        loadSelection()
        loadTimeLimitSelection()
        loadCancelledEvents()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.evaluateBlocking()
            self.scheduleTodayBlockingEvents()
        }
    }


    // MARK: - Blocking Evaluation Timer
    func startMonitoringLimits() {
        let center = DeviceActivityCenter()

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

        print("📝 Starting to prepare \(appLimits.count) app limits for monitoring...")

        for limit in appLimits {
            guard let token = limit.token else {
                print("❌ Failed to decode token for app limit with ID: \(limit.id)")
                continue
            }

            let eventName = DeviceActivityEvent.Name("limit-\(limit.id.uuidString)")
            let threshold = DateComponents(minute: limit.dailyLimitMinutes)

            print("🔧 Configuring limit: \(limit.dailyLimitMinutes) mins for token: \(token)")
            print("📛 Event name: \(eventName.rawValue)")

            events[eventName] = DeviceActivityEvent(
                applications: Set([token]),
                threshold: threshold
            )
        }

        if events.isEmpty {
            print("⚠️ No valid events to monitor — did all token decodings fail?")
            return
        }

        do {
            try center.startMonitoring(
                DeviceActivityName("DailyAppLimits"),
                during: schedule,
                events: events
            )
            print("📈 Monitoring started with \(events.count) events")
        } catch {
            print("❌ Monitoring failed: \(error)")
        }
    }

    
    private let timeLimitSelectionKey = "SavedTimeLimitSelection"

    func saveTimeLimitSelection() {
        do {
            let data = try PropertyListEncoder().encode(timeLimitSelection)
            UserDefaults.standard.set(data, forKey: timeLimitSelectionKey)
            print("✅ Saved TimeLimit FamilyActivitySelection")
        } catch {
            print("❌ Failed to save TimeLimit selection: \(error)")
        }
    }

    func loadTimeLimitSelection() {
        guard let data = UserDefaults.standard.data(forKey: timeLimitSelectionKey) else {
            print("ℹ️ No saved time limit selection found")
            return
        }

        do {
            let restored = try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
            DispatchQueue.main.async {
                self.timeLimitSelection = restored
                print("✅ Loaded saved TimeLimit FamilyActivitySelection")
                for token in restored.applicationTokens {
                    print("📱 Selected token: \(token)")
                }
            }
        } catch {
            print("❌ Failed to decode TimeLimit FamilyActivitySelection: \(error)")
        }
    }


    func reapplyTimeLimitShieldsIfNeeded() {
        let timestampsKey = "LimitHitTimestamps"
        let now = Date()
        let calendar = Calendar.current

        guard let timestampDict = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.dictionary(forKey: timestampsKey) as? [String: Date] else {
            print("ℹ️ No limit hit timestamps found")
            return
        }

        let tokensToBlock: [ApplicationToken] = appLimits.compactMap { limit in
            guard let token = limit.token,
                  let encoded = try? PropertyListEncoder().encode(token) else {
                return nil
            }

            let id = encoded.base64EncodedString()

            if let hitDate = timestampDict[id], calendar.isDate(hitDate, inSameDayAs: now) {
                return token
            }

            return nil
        }

        if !tokensToBlock.isEmpty {
            timeLimitStore.shield.applications = Set(tokensToBlock)
            print("🛡️ Reapplied shields for \(tokensToBlock.count) app(s) that hit their limits today")
        } else {
            timeLimitStore.shield.applications = nil
            print("🔓 No apps currently blocked by time limits")
        }
    }




  //  func refreshMonitoringForTimeLimits() {
  //      print("🔄 App returned to foreground — refreshing time limit monitoring")
  //      startMonitoringLimits()
   // }

    // MARK: - App Limits Persistence

    func saveAppLimits() {
        do {
            let data = try PropertyListEncoder().encode(appLimits)
            UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.set(data, forKey: "SavedAppLimits")
            print("✅ App limits saved")
        } catch {
            print("❌ Failed to save app limits: \(error)")
        }
    }

    func loadAppLimits() {
        guard let data = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.data(forKey: "SavedAppLimits") else {
            print("ℹ️ No app limits found")
            return
        }

        print("📦 Raw SavedAppLimits size: \(data.count) bytes")

        do {
            let limits = try PropertyListDecoder().decode([AppTimeLimit].self, from: data)
            DispatchQueue.main.async {
                self.appLimits = limits
                print("✅ Loaded \(limits.count) app limits")
                for limit in limits {
                    print("🧠 Limit ID: \(limit.id), Minutes: \(limit.dailyLimitMinutes)")
                    if let token = limit.token {
                        print("🎯 Token decoded: \(token)")
                    } else {
                        print("❌ Token decoding failed for limit \(limit.id)")
                    }
                }
                self.startMonitoringLimits()
            }
        } catch {
            print("❌ Failed to load app limits: \(error)")
        }
    }




    func scheduleTodayBlockingEvents() {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.weekdaySymbols[calendar.component(.weekday, from: now) - 1]

        guard let todaysEvents = scheduleViewModel.blockingSchedule[today], !todaysEvents.isEmpty else {
            print("🟢 No blocking events to schedule today")
            return
        }

        for event in todaysEvents {
            var startComponents = event.start
            var endComponents = event.end

            startComponents.year = calendar.component(.year, from: now)
            startComponents.month = calendar.component(.month, from: now)
            startComponents.day = calendar.component(.day, from: now)

            endComponents.year = calendar.component(.year, from: now)
            endComponents.month = calendar.component(.month, from: now)
            endComponents.day = calendar.component(.day, from: now)

            guard let startDate = calendar.date(from: startComponents),
                  let endDate = calendar.date(from: endComponents),
                  endDate > now else {
                continue
            }

            let key = eventKey(name: event.name, start: startDate)
            if cancelledEvents.contains(key) { continue }

            if now >= startDate && now <= endDate {
                print("🚨 Already in active blocking window: \(event.name)")
                startScheduledBlocking(start: startDate, end: endDate)
            } else {
                let timeUntilStart = startDate.timeIntervalSinceNow
                Timer.scheduledTimer(withTimeInterval: timeUntilStart, repeats: false) { [weak self] _ in
                    print("🔒 Starting blocking session: \(event.name)")
                    self?.startScheduledBlocking(start: startDate, end: endDate)
                }
            }
        }
    }


    func evaluateBlocking() {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        let today = calendar.weekdaySymbols[calendar.component(.weekday, from: now) - 1]

        // ✅ Auto-complete any sessions that just ended (move this UP)
        let activeKeys = sessionManager?.sessions
            .filter { session in
                session.startTime <= now && session.endTime >= now
            }
            .compactMap { sessionManager?.eventKey(name: $0.name, start: $0.startTime) } ?? []

        let endedKeys = lastActiveSessionKeys.subtracting(activeKeys)
        for key in endedKeys {
            if let session = sessionManager?.sessions.first(where: {
                sessionManager?.eventKey(name: $0.name, start: $0.startTime) == key
            }), sessionManager?.isManuallyEnded(name: session.name, start: session.startTime) == false {
                sessionManager?.completeAutoEndedSession(session)
            }
        }

        lastActiveSessionKeys = Set(activeKeys)

        // Continue evaluating whether we need to block right now
        guard let todaysEvents = scheduleViewModel.blockingSchedule[today], !todaysEvents.isEmpty else {
            presetStore.shield.applications = nil
            print("🟢 No blocking events for today (\(today))")
            return
        }

        for event in todaysEvents {
            guard isTime(currentComponents, within: event.start, and: event.end) else { continue }

            var fullStartComponents = event.start
            fullStartComponents.year = calendar.component(.year, from: now)
            fullStartComponents.month = calendar.component(.month, from: now)
            fullStartComponents.day = calendar.component(.day, from: now)

            guard let startDate = calendar.date(from: fullStartComponents) else { continue }
            let key = eventKey(name: event.name, start: startDate)

            if cancelledEvents.contains(key) {
                print("🚫 Skipping canceled event '\(event.name)'")
                continue
            }

            if sessionManager?.isManuallyEnded(name: event.name, start: startDate) == true {
                print("🚫 Skipping manually ended session: \(event.name)")
                continue
            }

            let tokens: Set<ApplicationToken>
            if let session = sessionManager?.sessions.first(where: { $0.name == event.name }),
               let selection = session.selection {
                tokens = selection.applicationTokens
                print("⛔ Blocking due to '\(event.name)' (from session)")
            } else {
                tokens = selection.applicationTokens
                print("⛔ Blocking due to '\(event.name)' (fallback)")
            }

            if !tokens.isEmpty {
                presetStore.shield.applications = tokens
                print("🛡️ Blocking \(tokens.count) apps")
            } else {
                presetStore.shield.applications = nil
                print("⚠️ No apps to block for '\(event.name)'")
            }

            return // keep this, but now it won't prevent auto-end logic
        }

        presetStore.shield.applications = nil
        print("🟢 No active blocking right now")
    }

    // MARK: - Time Comparison

    private func isTime(_ current: DateComponents, within start: DateComponents, and end: DateComponents) -> Bool {
        let calendar = Calendar.current

        guard let now = calendar.date(from: current),
              let startDate = calendar.date(from: start),
              let endDate = calendar.date(from: end) else {
            return false
        }

        if startDate <= endDate {
            // Normal case: 10 AM to 6 PM
            return now >= startDate && now <= endDate
        } else {
            // Overnight case: 10 PM to 6 AM
            return now >= startDate || now <= endDate
        }
    }


    // MARK: - Cancel Event

    func cancelEvent(named name: String, on start: Date) {
        let key = eventKey(name: name, start: start)
        cancelledEvents.insert(key)
        saveCancelledEvents()

        // Remove from schedule
        scheduleViewModel.removeEvent(named: name, on: start)

        // Remove session if exists
        sessionManager?.removeSession(name: name, startTime: start)

        // Clear blocking immediately and prevent re-evaluation
        let store = ManagedSettingsStore()
        store.shield.applications = nil
        unblockTimer?.invalidate()
        unblockTimer = nil
        blockEnd = nil
        
        print("🚫 Cancelled event '\(name)' at \(start) - blocking immediately stopped")
    }


    private func eventKey(name: String, start: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return "\(name)-\(formatter.string(from: start))"
    }

    private func saveCancelledEvents() {
        let array = Array(cancelledEvents)
        UserDefaults.standard.set(array, forKey: cancelledEventsKey)
    }

    private func loadCancelledEvents() {
        if let array = UserDefaults.standard.stringArray(forKey: cancelledEventsKey) {
            cancelledEvents = Set(array)
        }
    }

    // MARK: - Manual Scheduled Blocking

    func startScheduledBlocking(start: Date, end: Date) {
        if let sessionManager = sessionManager {
            let sessionKey = eventKey(name: "", start: start)
            
            if let activeSession = sessionManager.sessions.first(where: {
                Calendar.current.isDate($0.startTime, equalTo: start, toGranularity: .minute)
            }), let tokens = activeSession.selection?.applicationTokens {
                presetStore.shield.applications = tokens
                print("🔒 Blocking apps from \(start) to \(end) using session: \(activeSession.name)")
            } else {
                presetStore.shield.applications = selection.applicationTokens
                print("🔒 Blocking apps from \(start) to \(end) using fallback selection")
            }
        } else {
            presetStore.shield.applications = selection.applicationTokens
            print("🔒 Blocking apps from \(start) to \(end) — sessionManager was nil, using fallback")
        }

        blockEnd = end
        scheduleUnblock(at: end)
    }


    private func scheduleUnblock(at date: Date) {
        unblockTimer?.invalidate()
        let interval = max(0, date.timeIntervalSinceNow)
        unblockTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.unblockApps()
        }
    }

    private func unblockApps() {
        presetStore.shield.applications = nil
        print("✅ Auto-unblocked apps at \(Date())")
        unblockTimer = nil
        blockEnd = nil
    }

    func clearBlocking() {
        unblockTimer?.invalidate()
        unblockApps()
    }
    
   

    // MARK: - Screen Time Authorization

    func requestScreenTimeAuthorization() {
        #if targetEnvironment(simulator)
        authorizationStatus = .approved
        #else
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                let status = AuthorizationCenter.shared.authorizationStatus
                switch status {
                case .approved:
                    authorizationStatus = .approved
                case .denied:
                    authorizationStatus = .denied
                default:
                    authorizationStatus = .notDetermined
                }
            } catch {
                authorizationStatus = .denied
            }
        }
        #endif
    }

    // MARK: - Selection Persistence

    func saveSelection() {
        do {
            let data = try PropertyListEncoder().encode(selection)
            UserDefaults.standard.set(data, forKey: savedSelectionKey)
            print("✅ Saved FamilyActivitySelection")
        } catch {
            print("❌ Failed to save selection: \(error)")
        }
    }

    func loadSelection() {
        guard let data = UserDefaults.standard.data(forKey: savedSelectionKey) else {
            print("ℹ️ No saved selection found")
            return
        }

        do {
            let restored = try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
            DispatchQueue.main.async {
                self.selection = restored
                print("✅ Loaded saved FamilyActivitySelection")
            }
        } catch {
            print("❌ Failed to decode FamilyActivitySelection: \(error)")
        }
    }

    func applyAppShielding() {
        presetStore.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
    }

    // MARK: - Labels

    func saveLabels(_ labels: [String]) {
        blockedAppLabels = labels
        UserDefaults.standard.set(labels, forKey: labelKey)
    }

    func loadSavedLabels() {
        blockedAppLabels = UserDefaults.standard.stringArray(forKey: labelKey) ?? []
    }

    // MARK: - Mock Usage Data

    func simulateUsageIfNeeded() {
        appUsage = ["Instagram": 45, "YouTube": 70, "WhatsApp": 25]
        hourlyUsage = [9: 10, 10: 15, 11: 20, 13: 40]
        weeklyUsage = ["Mon": 3.5, "Tue": 2.8, "Wed": 4.1, "Thu": 2.5, "Fri": 3.2, "Sat": 2.9, "Sun": 2.1]
        moodEntries = (0..<4).map {
            MoodEntry(date: Date().addingTimeInterval(Double(-86400 * (3 - $0))), moodLevel: Int.random(in: 2...5))
        }
    }

    // MARK: - Usage Logging

    func logAppUsage(app: String, duration: Int) {
        appUsage[app, default: 0] += duration
        let hour = Calendar.current.component(.hour, from: Date())
        hourlyUsage[hour, default: 0] += duration

        let weekday = DateFormatter().shortWeekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
        weeklyUsage[weekday, default: 0] += Double(duration) / 60.0
    }

    func addMoodEntry(_ entry: MoodEntry) {
        moodEntries.append(entry)
    }

    func recordNotification(at hour: Int) {
        if (0..<24).contains(hour) {
            notificationsPerHour[hour] += 1
        }
    }
}

