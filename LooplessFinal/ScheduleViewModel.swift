//
//  ScheduleViewModel.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//

import SwiftUI

class ScheduleViewModel: ObservableObject {
    // Legacy hourly schedule structure
    @Published var schedules: [String: [Int: String]] = [:]

    // Per-day minute-level blocking events
    @Published var blockingSchedule: [String: [BlockingEvent]] = [:] {
        didSet {
            saveBlockingSchedule()
        }
    }

    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private let blockingScheduleKey = "BlockingScheduleData"

    // MARK: - BlockingEvent Struct
    struct BlockingEvent: Identifiable, Codable, Equatable {
        let id = UUID()
        let name: String
        let start: DateComponents
        let end: DateComponents

        static func ==(lhs: BlockingEvent, rhs: BlockingEvent) -> Bool {
            lhs.id == rhs.id
        }
    }

    // MARK: - Init
    init() {
        // Initialize legacy schedule
        for day in daysOfWeek {
            schedules[day] = [:]
            for hour in 0..<24 {
                schedules[day]?[hour] = "No Activity"
            }
        }

        // Load saved blocking events
        loadBlockingSchedule()
    }

    // MARK: - Add Blocking Event
    func addBlockingEvent(name: String, for day: String, start: DateComponents, end: DateComponents) {
        var events = blockingSchedule[day] ?? []
        let newEvent = BlockingEvent(name: name, start: start, end: end)
        events.append(newEvent)
        blockingSchedule[day] = events
        print("🗓️ Added '\(name)' to \(day) from \(start.hour ?? 0):\(start.minute ?? 0) to \(end.hour ?? 0):\(end.minute ?? 0)")
    }

    
    // MARK: - Delete Blocking Event
    func removeBlockingEvent(_ event: BlockingEvent, from day: String) {
        guard var events = blockingSchedule[day] else { return }
        events.removeAll { $0.id == event.id }
        blockingSchedule[day] = events
        print("🗑️ Removed '\(event.name)' from \(day)")
    }
    
    func removeEvent(named name: String, on start: Date) {
        let calendar = Calendar.current
        for day in daysOfWeek {
            guard var events = blockingSchedule[day] else { continue }

            events.removeAll { event in
                guard let eventStartDate = calendar.date(from: event.start) else { return false }
                return event.name == name &&
                       calendar.isDate(eventStartDate, equalTo: start, toGranularity: .minute)
            }

            blockingSchedule[day] = events
        }
    }


    func clearAllBlockingEvents() {
        for day in daysOfWeek {
            blockingSchedule[day] = []
        }
        saveBlockingSchedule()
        print("🧹 Cleared all blocking events")
    }

    // MARK: - Retrieve
    func blockingEvents(for day: String) -> [BlockingEvent] {
        blockingSchedule[day] ?? []
    }

    // MARK: - Persistence
    private func saveBlockingSchedule() {
        do {
            let data = try JSONEncoder().encode(blockingSchedule)
            UserDefaults.standard.set(data, forKey: blockingScheduleKey)
        } catch {
            print("❌ Failed to save blocking schedule: \(error)")
        }
    }

    private func loadBlockingSchedule() {
        guard let data = UserDefaults.standard.data(forKey: blockingScheduleKey) else { return }
        do {
            blockingSchedule = try JSONDecoder().decode([String: [BlockingEvent]].self, from: data)
        } catch {
            print("❌ Failed to load blocking schedule: \(error)")
        }
    }

    // MARK: - Legacy Methods
    func applyCustomEvent(name: String, days: [String], hours: Set<Int>) {
        for day in days {
            for hour in hours {
                if schedules[day] == nil {
                    schedules[day] = [:]
                }
                schedules[day]?[hour] = name
            }
        }
    }

    func setActivity(_ activity: String, for day: String, hours: Set<Int>) {
        for hour in hours {
            schedules[day, default: [:]][hour] = activity
        }
    }

    func hoursOfActivity(_ activity: String, on day: String) -> Int {
        schedules[day]?.values.filter { $0 == activity }.count ?? 0
    }

    func weeklyHoursOfActivity(_ activity: String) -> Int {
        daysOfWeek.reduce(0) { total, day in
            total + hoursOfActivity(activity, on: day)
        }
    }

    func weeklyActivityTypes() -> Set<String> {
        var set = Set<String>()
        for day in daysOfWeek {
            set.formUnion(schedules[day]?.values.filter {
                $0 != "No Activity" && $0 != "Sleep"
            } ?? [])
        }
        return set
    }

    func daysExceedingFreeTime(maxHours: Int) -> Int {
        daysOfWeek.filter { day in
            let free = hoursOfActivity("No Activity", on: day) + hoursOfActivity("Screen Time", on: day)
            return free > maxHours
        }.count
    }

    func calculateScheduleAdherence() -> Double {
        var totalHours = 0
        var focusedHours = 0

        for day in daysOfWeek {
            guard let daily = schedules[day] else { continue }
            for (_, activity) in daily {
                totalHours += 1
                if activity != "No Activity" && activity != "Screen Time" {
                    focusedHours += 1
                }
            }
        }

        guard totalHours > 0 else { return 0.0 }
        return Double(focusedHours) / Double(totalHours)
    }
}

