import SwiftUI
import FamilyControls

struct SessionKey: Hashable {
    let name: String
    let dayOfWeek: String
}

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
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    Text("Sessions")
                        .font(Font.custom("Avenir Next", size: 36).weight(.semibold))
                        .tracking(0.5)
                        .foregroundColor(.clear)
                        .overlay(
                            LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .mask(
                                    Text("Sessions")
                                        .font(Font.custom("Avenir Next", size: 36).weight(.semibold))
                                )
                        )
                        .shadow(color: Color.blue.opacity(0.25), radius: 5, x: 0, y: 3)
                        .padding(.top, 36)

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
                                startTime: timeFromComponents(event.start),
                                endTime: timeFromComponents(event.end),
                                dayOfWeek: day
                            )
                        }
                    }

                    let upcomingSessions = allScheduledEvents.filter { session in
                        let sessionDayIndex = weekdaySymbols.firstIndex(of: session.dayOfWeek)! + 1
                        return sessionDayIndex > todayIndex || (sessionDayIndex == todayIndex && session.startTime > now)
                    }

                    let activeSessionKeys = Set(activeSessions.map { SessionKey(name: $0.name, dayOfWeek: $0.dayOfWeek) })
                    let completedSessions = allScheduledEvents.filter { session in
                        let sessionDayIndex = weekdaySymbols.firstIndex(of: session.dayOfWeek)! + 1
                        let isTodayAndPastEnd = sessionDayIndex == todayIndex && session.endTime < now
                        let key = SessionKey(name: session.name, dayOfWeek: session.dayOfWeek)
                        return isTodayAndPastEnd && !activeSessionKeys.contains(key)
                    }

                    if !activeSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🟢 Active")
                                .font(.headline)
                                .foregroundColor(.cyan)
                                .padding(.leading)

                            ForEach(activeSessions) { session in
                                SessionCardView(session: session, evaluator: evaluator) {
                                    sessionPendingEarlyEnd = session
                                    showFireHoldView = true
                                }
                            }
                        }
                    }

                    if !upcomingSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🗓 Upcoming")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.leading)

                            ForEach(upcomingSessions) { session in
                                SessionCardView(session: session, evaluator: evaluator)
                            }
                        }
                    }

                    if !completedSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Button(action: {
                                showCompletedTogglePopup = true
                            }) {
                                HStack {
                                    Text("✅ Completed")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding(.horizontal)
                            }

                            if showCompleted {
                                ForEach(completedSessions) { session in
                                    SessionCardView(session: session, evaluator: evaluator)
                                }
                            }
                        }
                    }

                    if activeSessions.isEmpty && upcomingSessions.isEmpty && (!showCompleted || completedSessions.isEmpty) {
                        Text("No active, upcoming, or visible completed sessions.")
                            .foregroundColor(.gray)
                            .italic()
                            .font(.system(size: 16, design: .rounded))
                            .padding()
                    }
                }
                .padding(.bottom, 40)
            }
            .background(
                LinearGradient(colors: [Color.black, Color.blue.opacity(0.15), Color.black],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .blur(radius: showCompletedTogglePopup ? 3 : 0)

            if showReflectionPopup {
                Color.black.opacity(0.4).ignoresSafeArea()

                ReflectionPopupView {
                    showReflectionPopup = false
                }
                .frame(maxWidth: 350)
                .padding()
                .transition(.scale)
                .zIndex(1)
            }

            if showCompletedTogglePopup {
                Color.black.opacity(0.6).ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Completed Sessions")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("Would you like to hide completed sessions?")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))

                    HStack(spacing: 20) {
                        Button("Hide") {
                            showCompleted = false
                            showCompletedTogglePopup = false
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                        Button("Keep Showing") {
                            showCompleted = true
                            showCompletedTogglePopup = false
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                }
                .padding()
                .frame(maxWidth: 350)
                .background(Color.black.opacity(0.9))
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.scale)
                .zIndex(2)
            }
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
        .onAppear {
            sessionManager.loadTodaySessions(from: dataModel.scheduleViewModel, selection: dataModel.selection)
        }

    }

    private func timeFromComponents(_ components: DateComponents) -> Date {
        Calendar.current.date(from: components) ?? Date()
    }
}

struct SessionCardView: View {
    let session: BlockingEvent
    @EnvironmentObject var sessionManager: BlockingSessionManager
    @EnvironmentObject var dataModel: LooplessDataModel
    var evaluator: RewardsEvaluator
    var onRequestEndEarly: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lock.circle")
                    .foregroundColor(.cyan)
                Text(session.name)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
            }

            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                Text(session.dayOfWeek)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }

            HStack(spacing: 10) {
                Image(systemName: "clock")
                    .foregroundColor(.gray)
                Text("\(formattedTime(session.startTime)) - \(formattedTime(session.endTime))")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }

            if let selection = session.selection {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Blocked Apps")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)

                    ForEach(Array(selection.applicationTokens), id: \.self) { token in
                        Label(token)
                            .font(.system(size: 14, design: .rounded))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.cyan.opacity(0.15))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.cyan.opacity(0.4), lineWidth: 1)
                            )
                    }
                }
            } else {
                Text("⚠️ Could not decode selection.")
                    .foregroundColor(.red)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }

            if session.startTime <= Date() && session.endTime >= Date() {
                Button(action: {
                    onRequestEndEarly?()
                }) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("End Session Early")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.03))
                .background(.ultraThinMaterial)
                .shadow(color: Color.cyan.opacity(0.2), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(colors: [.cyan.opacity(0.4), .blue.opacity(0.3)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.2
                        )
                )
        )
        .padding(.horizontal)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

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

