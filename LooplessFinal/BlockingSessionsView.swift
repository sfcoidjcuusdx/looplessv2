import SwiftUI
import FamilyControls

// MARK: - SessionKey

struct SessionKey: Hashable {
    let name: String
    let startTime: Date
}


// MARK: - Main View

struct BlockingSessionsView: View {
    @EnvironmentObject var dataModel: LooplessDataModel
    @EnvironmentObject var sessionManager: BlockingSessionManager
    @EnvironmentObject var evaluator: RewardsEvaluator
    @Binding var selectedTab: AppTab
    @Binding var showReflectionPopup: Bool

    @State private var showFireHoldView = false
    @State private var sessionPendingEarlyEnd: BlockingEvent?
    @State private var showCompleted = true
    @State private var showCompletedTogglePopup = false

    var body: some View {
        NavigationStack {
            List {
                let now = Date()
                let calendar = Calendar.current
                let todayIndex = calendar.component(.weekday, from: now)
                let weekdaySymbols = calendar.weekdaySymbols
                
                let (activeSessions, _) = sessionManager.sessions.partitioned {
                    let endPlusBuffer = calendar.date(byAdding: .minute, value: 1, to: $0.endTime)!
                    return $0.startTime <= now && endPlusBuffer > now && !sessionManager.isManuallyEnded(name: $0.name, start: $0.startTime)
                }
                
                let allScheduledEvents: [BlockingEvent] = dataModel.scheduleViewModel.daysOfWeek.flatMap { day in
                    dataModel.scheduleViewModel.blockingEvents(for: day).map { event in
                        BlockingEvent(
                            id: UUID(),
                            name: event.name,
                            selectionData: try! PropertyListEncoder().encode(dataModel.selection),
                            startTime: dateFor(dayOfWeek: day, time: event.start),
                            endTime: dateFor(dayOfWeek: day, time: event.end),
                            dayOfWeek: day
                        )
                    }
                }

                
                let upcomingSessions = allScheduledEvents.filter { session in
                    let sessionDayIndex = weekdaySymbols.firstIndex(of: session.dayOfWeek)! + 1
                    return sessionDayIndex > todayIndex || (sessionDayIndex == todayIndex && session.startTime > now)
                }
                let activeSessionKeys = Set(activeSessions.map { SessionKey(name: $0.name, startTime: $0.startTime) })
                let completedSessions = allScheduledEvents.filter { session in
                    let key = SessionKey(name: session.name, startTime: session.startTime)

                    let hasStarted = session.startTime <= now
                    let hasEnded = session.endTime < now

                    return hasStarted && hasEnded && !activeSessionKeys.contains(key)
                }


                
                // MARK: - Active
                if !activeSessions.isEmpty {
                    Section(header: Text("Active Sessions")) {
                        ForEach(activeSessions) { session in
                            SessionCardView(session: session, evaluator: evaluator) {
                                sessionPendingEarlyEnd = session
                                showFireHoldView = true
                            }
                        }
                    }
                }
                
                // MARK: - Upcoming
                if !upcomingSessions.isEmpty {
                    Section(header: Text("Upcoming Sessions")) {
                        ForEach(upcomingSessions) { session in
                            SessionCardView(session: session, evaluator: evaluator)
                        }
                    }
                }
                
                // MARK: - Completed
                if !completedSessions.isEmpty {
                    Section {
                        Button(action: {
                            showCompletedTogglePopup = true
                        }) {
                            HStack {
                                Text(showCompleted ? "Hide Completed" : "Show Completed")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        
                        if showCompleted {
                            ForEach(completedSessions) { session in
                                SessionCardView(session: session, evaluator: evaluator)
                            }
                        }
                    } header: {
                        Text("Completed Sessions")
                    }
                }
                
                if activeSessions.isEmpty && upcomingSessions.isEmpty && (!showCompleted || completedSessions.isEmpty) {
                    Section {
                        Text("No active, upcoming, or visible completed sessions.")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Blocking Sessions")
            .sheet(isPresented: $showCompletedTogglePopup) {
                CompletedToggleSheet(showCompleted: $showCompleted)
            }
            .fullScreenCover(isPresented: $showFireHoldView) {
                if let session = sessionPendingEarlyEnd {
                    FireHoldToEndView {
                        sessionManager.endSession(session)
                        dataModel.cancelEvent(named: session.name, on: session.startTime)
                        showFireHoldView = false
                        sessionPendingEarlyEnd = nil
                    } onCancel: {
                        showFireHoldView = false
                        sessionPendingEarlyEnd = nil
                    }
                }
            }
            .fullScreenCover(isPresented: $showReflectionPopup) {
                ReflectionPopupView {
                    showReflectionPopup = false
                }
                .navigationBarHidden(true)
            }
            .onAppear {
                
                    sessionManager.loadTodaySessions(from: dataModel.scheduleViewModel, selection: dataModel.selection)

                    for session in sessionManager.sessions {
                    }

                    let now = Date()
                    let activeSessions = sessionManager.sessions.filter {
                        $0.startTime <= now && $0.endTime >= now
                    }
                }

            }
        }
    
    func debugPrintCurrentState() {
            let now = Date()
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .medium
            
            print("\n===== DEBUG SESSION STATE =====")
            print("Current time: \(formatter.string(from: now))")
            
            // Print all sessions
            print("\nAll Sessions:")
            for session in sessionManager.sessions {
                print("\(session.name): \(formatter.string(from: session.startTime)) - \(formatter.string(from: session.endTime))")
            }
            
            // Print active sessions
            let activeSessions = sessionManager.sessions.filter {
                $0.startTime <= now && $0.endTime >= now
            }
            print("\nActive Sessions (\(activeSessions.count)):")
            activeSessions.forEach { print($0.name) }
            
            // Print schedule
            print("\nSchedule View Model Events:")
            for day in dataModel.scheduleViewModel.daysOfWeek {
                let events = dataModel.scheduleViewModel.blockingEvents(for: day)
                if !events.isEmpty {
                    print("\(day):")
                    events.forEach { event in
                        print("  \(event.name): \(event.start.hour ?? 0):\(event.start.minute ?? 0) - \(event.end.hour ?? 0):\(event.end.minute ?? 0)")
                    }
                }
            }
            print("=============================\n")
        }
    }
    
    private func timeFromComponents(_ components: DateComponents) -> Date {
        Calendar.current.date(from: components) ?? Date()
    }


// MARK: - Completed Toggle Sheet

struct CompletedToggleSheet: View {
    @Binding var showCompleted: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Completed Sessions")
                    .font(.title2)
                    .padding(.top)

                Text("Would you like to hide completed sessions?")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Hide Completed") {
                    showCompleted = false
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

                Button("Keep Showing") {
                    showCompleted = true
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                Spacer()
            }
            .padding()
            .navigationTitle("Options")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Session Card View

struct SessionCardView: View {
    let session: BlockingEvent
    @EnvironmentObject var sessionManager: BlockingSessionManager
    @EnvironmentObject var dataModel: LooplessDataModel
    var evaluator: RewardsEvaluator
    var onRequestEndEarly: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.name)
                .font(.headline)

            Text(session.dayOfWeek)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("\(formattedTime(session.startTime)) - \(formattedTime(session.endTime))")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let selection = session.selection {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(selection.applicationTokens), id: \.self) { token in
                        Label(token)
                            .font(.caption2)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.white)
                            .cornerRadius(6)
                            .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
                    }

                }
                .padding(.top, 4)
            } else {
                Text("Could not decode blocked apps.")
                    .font(.footnote)
                    .foregroundColor(.red)
            }

            if session.startTime <= Date() && session.endTime >= Date() {
                Button(action: {
                    onRequestEndEarly?()
                }) {
                    Label("End Session Early", systemImage: "xmark.circle")
                        .font(.footnote)
                        .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .padding(.top, 6)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

func dateFor(dayOfWeek: String, time: DateComponents) -> Date {
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


// MARK: - Partition Extension

extension Array {
    func partitioned(by predicate: (Element) -> Bool) -> (matching: [Element], nonMatching: [Element]) {
        var matching = [Element]()
        var nonMatching = [Element]()
        for element in self {
            if predicate(element) {
                matching.append(element)
            } else {
                nonMatching.append(element)
            }
        }
        return (matching, nonMatching)
    }
}

