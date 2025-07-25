//
//  BlockingSessionManager.swift
//  LooplessFinal
//

import SwiftUI
import FamilyControls

// MARK: - BlockingEvent Model
struct BlockingEvent: Identifiable, Codable {
    let id: UUID
    let name: String
    let selectionData: Data
    let startTime: Date
    let endTime: Date
    let dayOfWeek: String

    var selection: FamilyActivitySelection? {
        try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: selectionData)
    }
}

// MARK: - BlockingSessionManager
class BlockingSessionManager: ObservableObject {
    @Published var sessions: [BlockingEvent] = []
    @Published var manuallyEndedEventKeys: Set<String> = []
    @Published var redeemedMinutes: Int = 0

    /// Injected rewards evaluator (optional, must be set externally)
    var rewardsEvaluator: RewardsEvaluator?

    private let sessionsKey = "SavedBlockingSessions"
    private let endedKeysKey = "ManuallyEndedEventKeys"

    init() {
        loadSessions()
        loadEndedKeys()
    }

    internal func eventKey(name: String, start: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return "\(name)-\(formatter.string(from: start))"
    }
    
    func removeSession(name: String, startTime: Date) {
        sessions.removeAll {
            $0.name == name && Calendar.current.isDate($0.startTime, equalTo: startTime, toGranularity: .minute)
        }
    }


    
    func isManuallyEnded(name: String, start: Date) -> Bool {
        let key = eventKey(name: name, start: start)
        return manuallyEndedEventKeys.contains(key)
    }

    func endSession(_ session: BlockingEvent) {
        let key = eventKey(name: session.name, start: session.startTime)
        manuallyEndedEventKeys.insert(key)
        sessions.removeAll { $0.id == session.id }
        saveEndedKeys()
        saveSessions()

        print("🛑 Session '\(session.name)' ended manually. No reward increment.")
        
        // ❌ Do NOT increment `completedSessionCount`
        // ❌ Do NOT evaluate rewards
    }

    func loadTodaySessions(from scheduleViewModel: ScheduleViewModel, selection: FamilyActivitySelection) {
        // 1. Setup basic date components on main thread
        let calendar = Calendar.current
        let now = Date()
        let todayIndex = calendar.component(.weekday, from: now) - 1
        let weekdaySymbols = calendar.weekdaySymbols
        
        // 2. Process in background to avoid UI lag
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 3. Calculate days to check (yesterday and today)
            let daysToCheck = [(todayIndex - 1 + 7) % 7, todayIndex]
            var newSessions: [BlockingEvent] = []
            
            // 4. Process each day
            for dayIndex in daysToCheck {
                let day = weekdaySymbols[dayIndex]
                guard let events = scheduleViewModel.blockingSchedule[day] else { continue }
                
                // 5. Process events in batches
                for event in events.prefix(10) { // Limit to 10 events per day
                    guard let (startDate, endDate) = self.calculateSessionDates(
                        event: event,
                        dayIndex: dayIndex,
                        day: day,
                        now: now,
                        calendar: calendar
                    ) else { continue }
                    
                    // 6. Check if session is active
                    if now >= startDate && now <= endDate {
                        let sessionKey = self.eventKey(name: event.name, start: startDate)
                        
                        // 7. Check for existing session
                        if !self.sessions.contains(where: {
                            self.eventKey(name: $0.name, start: $0.startTime) == sessionKey
                        }) {
                            if let newSession = self.createSession(
                                event: event,
                                startDate: startDate,
                                endDate: endDate,
                                day: day,
                                selection: selection
                            ) {
                                newSessions.append(newSession)
                            }
                        }
                    }
                }
            }
            
            // 8. Update on main thread
            DispatchQueue.main.async {
                self.sessions.append(contentsOf: newSessions)
                self.cleanupExpiredSessions(now: now)
            }
        }
    }

    // Helper function to calculate dates safely
    private func calculateSessionDates(
        event: ScheduleViewModel.BlockingEvent,
        dayIndex: Int,
        day: String,
        now: Date,
        calendar: Calendar
    ) -> (start: Date, end: Date)? {
        var startComponents = event.start
        var endComponents = event.end
        
        // Calculate target date (today or yesterday)
        let targetDate = dayIndex == calendar.component(.weekday, from: now) - 1 ?
            now : calendar.date(byAdding: .day, value: -1, to: now)!
        
        // Configure date components
        startComponents.year = calendar.component(.year, from: targetDate)
        startComponents.month = calendar.component(.month, from: targetDate)
        startComponents.day = calendar.component(.day, from: targetDate)
        
        endComponents.year = calendar.component(.year, from: targetDate)
        endComponents.month = calendar.component(.month, from: targetDate)
        endComponents.day = calendar.component(.day, from: targetDate)
        
        // Safely unwrap dates
        guard let startDate = calendar.date(from: startComponents),
              let tentativeEndDate = calendar.date(from: endComponents) else {
            return nil
        }
        
        // Handle overnight sessions
        let endDate = tentativeEndDate > startDate ?
            tentativeEndDate : calendar.date(byAdding: .day, value: 1, to: tentativeEndDate)!
        
        return (startDate, endDate)
    }

    // Helper function to create sessions safely
    private func createSession(
        event: ScheduleViewModel.BlockingEvent,
        startDate: Date,
        endDate: Date,
        day: String,
        selection: FamilyActivitySelection
    ) -> BlockingEvent? {
        do {
            let encoded = try PropertyListEncoder().encode(selection)
            return BlockingEvent(
                id: UUID(),
                name: event.name,
                selectionData: encoded,
                startTime: startDate,
                endTime: endDate,
                dayOfWeek: day
            )
        } catch {
            print("❌ Failed to encode session: \(error)")
            return nil
        }
    }

    // Helper function to clean up sessions
    private func cleanupExpiredSessions(now: Date) {
        sessions.removeAll { $0.endTime < now }
        saveSessions()
    }


    func completeAutoEndedSession(_ session: BlockingEvent) {
        // Auto-end logic (without marking as manually ended)
        sessions.removeAll { $0.id == session.id }
        saveSessions()

        let current = UserDefaults.standard.integer(forKey: "completedSessionCount")
        let updated = current + 1
        UserDefaults.standard.set(updated, forKey: "completedSessionCount")
        print("📈 Auto-ended session count incremented to \(updated)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.rewardsEvaluator?.evaluateAllGoals()
        }
    }



    func addSession(name: String, selection: FamilyActivitySelection, start: Date, end: Date, dayOfWeek: String) {
        do {
            let encoded = try PropertyListEncoder().encode(selection)
            let newSession = BlockingEvent(
                id: UUID(),
                name: name,
                selectionData: encoded,
                startTime: start,
                endTime: end,
                dayOfWeek: dayOfWeek
            )
            sessions.append(newSession)
            saveSessions()
        } catch {
            print("❌ Failed to encode FamilyActivitySelection: \(error)")
        }
    }

    private func saveSessions() {
        do {
            let encoded = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        } catch {
            print("❌ Failed to save blocking sessions: \(error)")
        }
    }

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey) else { return }
        do {
            sessions = try JSONDecoder().decode([BlockingEvent].self, from: data)
        } catch {
            print("❌ Failed to load blocking sessions: \(error)")
        }
    }

    private func saveEndedKeys() {
        let array = Array(manuallyEndedEventKeys)
        UserDefaults.standard.set(array, forKey: endedKeysKey)
    }

    private func loadEndedKeys() {
        if let savedArray = UserDefaults.standard.array(forKey: endedKeysKey) as? [String] {
            manuallyEndedEventKeys = Set(savedArray)
        }
    }
}

