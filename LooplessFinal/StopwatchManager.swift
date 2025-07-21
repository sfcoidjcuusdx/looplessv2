import Foundation
import SwiftUI
import UIKit

class StopwatchManager: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning = false

    private var timer: Timer?
    private var backgroundEnteredAt: Date?
    private var brightnessWasZero: Bool = false

    private let elapsedTimeKey = "elapsedTime"
    private let isRunningKey = "isRunning"
    private let backgroundTimeKey = "backgroundEnteredAt"
    private let lastRecordedDateKey = "lastRecordedDate"

    private var lastTimerDate: Date = Date()
    private var lastRecordedDate: Date = Date()

    var formattedTimeHM: (hours: Int, minutes: Int) {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) / 60) % 60
        return (hours, minutes)
    }

    /// Called when a new day begins; sends previous day’s total
    var onDayChange: ((TimeInterval) -> Void)?

    init() {
        loadSavedState()
        restoreBackgroundTimeIfNeeded()

        if isRunning {
            startTimer()
        }
    }

    func start() {
        isRunning = true
        saveRunningState()
        startTimer()
    }

    func pause() {
        isRunning = false
        stopTimer()
        saveRunningState()
        saveElapsedTime()
    }

    private func startTimer() {
        stopTimer()
        lastTimerDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerFired()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func timerFired() {
        let now = Date()
        let calendar = Calendar.current

        if !calendar.isDate(now, inSameDayAs: lastRecordedDate) {
            print("🔄 Day changed from \(lastRecordedDate) to \(now)")
            onDayChange?(elapsedTime)
            elapsedTime = 0
            lastRecordedDate = now
            saveElapsedTime()
        }

        elapsedTime += 1
        lastTimerDate = now
        saveElapsedTime()
    }

    func didEnterBackground() {
        if isRunning {
            backgroundEnteredAt = Date()
            brightnessWasZero = UIScreen.main.brightness <= 0.05
            stopTimer()

            UserDefaults.standard.set(backgroundEnteredAt, forKey: backgroundTimeKey)
            saveElapsedTime()
            saveRunningState()
            print("📥 Saved backgroundEnteredAt: \(backgroundEnteredAt!)")
        }
    }

    func willEnterForeground() {
        if isRunning {
            let now = Date()
            let brightnessNow = UIScreen.main.brightness

            if let backgroundTime = backgroundEnteredAt {
                let calendar = Calendar.current

                if !calendar.isDate(now, inSameDayAs: lastRecordedDate) {
                    print("🔄 Day changed while in background.")
                    onDayChange?(elapsedTime)
                    elapsedTime = 0
                    lastRecordedDate = now
                }

                if !brightnessWasZero && brightnessNow > 0.05 {
                    let timeAway = now.timeIntervalSince(backgroundTime)
                    elapsedTime += timeAway
                    print("🟢 Added \(Int(timeAway)) seconds since background.")
                } else {
                    print("🛑 Skipped time because screen was off.")
                }

                backgroundEnteredAt = nil
                UserDefaults.standard.removeObject(forKey: backgroundTimeKey)
            }

            startTimer()
            saveElapsedTime()
        }
    }

    func resumeIfNeeded() {
        if isRunning {
            startTimer()
        }
    }

    // MARK: - Persistence

    private func saveElapsedTime() {
        UserDefaults.standard.set(elapsedTime, forKey: elapsedTimeKey)
        UserDefaults.standard.set(lastRecordedDate, forKey: lastRecordedDateKey)
    
    }

    private func saveRunningState() {
        UserDefaults.standard.set(isRunning, forKey: isRunningKey)
    }

    private func loadSavedState() {
        elapsedTime = UserDefaults.standard.double(forKey: elapsedTimeKey)
        isRunning = UserDefaults.standard.bool(forKey: isRunningKey)

        if let savedDate = UserDefaults.standard.object(forKey: lastRecordedDateKey) as? Date {
            lastRecordedDate = savedDate
        } else {
            lastRecordedDate = Date()
        }

        print("📤 Loaded elapsedTime: \(Int(elapsedTime))s, isRunning: \(isRunning), lastRecordedDate: \(lastRecordedDate)")
    }

    private func restoreBackgroundTimeIfNeeded() {
        if isRunning,
           let savedDate = UserDefaults.standard.object(forKey: backgroundTimeKey) as? Date {
            let now = Date()
            let calendar = Calendar.current

            if !calendar.isDate(now, inSameDayAs: lastRecordedDate) {
                print("🔄 Day changed while app was killed.")
                onDayChange?(elapsedTime)
                elapsedTime = 0
                lastRecordedDate = now
            }

            let timeAway = now.timeIntervalSince(savedDate)
            if timeAway > 0 {
                elapsedTime += timeAway
                print("♻️ Restored and added \(Int(timeAway))s from backgrounded app launch")
                saveElapsedTime()
            }

            UserDefaults.standard.removeObject(forKey: backgroundTimeKey)
        }
    }
}

