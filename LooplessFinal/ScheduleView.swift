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
        let todayName = Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]

        let events = scheduleViewModel.blockingEvents(for: todayName)

        for event in events {
            let start = Calendar.current.date(from: event.start) ?? Date()
            let end = Calendar.current.date(from: event.end) ?? Date().addingTimeInterval(3600)

            let existing = sessions.contains {
                $0.name == event.name && $0.dayOfWeek == todayName && $0.startTime == start
            }

            if !existing {
                addSession(name: event.name, selection: selection, start: start, end: end, dayOfWeek: todayName)
            }
        }
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

