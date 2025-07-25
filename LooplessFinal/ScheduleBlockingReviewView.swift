import SwiftUI

struct ScheduleBlockingView: View {
    @EnvironmentObject var dataModel: LooplessDataModel
    @EnvironmentObject var sessionManager: BlockingSessionManager

    @State private var selectedDays: Set<String> = []
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var eventName: String = ""
    @State private var showingAlert = false

    // Displayed initials + full names
    private let dayInitials = ["M", "T", "W", "T", "F", "S", "S"]
    private let fullNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Event Name Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Event Name")
                            .font(.headline)

                        TextField("e.g. Deep Work", text: $eventName)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // Day Picker Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Days")
                            .font(.headline)

                        HStack(spacing: 12) {
                            ForEach(dayInitials.indices, id: \.self) { index in
                                let initial = dayInitials[index]
                                let full = fullNames[index]
                                let isSelected = selectedDays.contains(full)

                                Button(action: {
                                    if isSelected {
                                        selectedDays.remove(full)
                                    } else {
                                        selectedDays.insert(full)
                                    }
                                }) {
                                    Text(initial)
                                        .font(.body)
                                        .frame(width: 36, height: 36)
                                        .background(isSelected ? Color.accentColor.opacity(0.2) : Color(UIColor.systemGray6))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // Time Picker Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Time Interval")
                            .font(.headline)

                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // Confirm Button
                    Button(action: handleConfirm) {
                        Text("Confirm & Apply")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white) // Full white background
            }
            .navigationTitle("New Blocking Session")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Missing Information", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please fill all fields and select a valid time range.")
            }
        }
    }

    private func handleConfirm() {
        guard !eventName.isEmpty, !selectedDays.isEmpty, startTime < endTime else {
            showingAlert = true
            return
        }

        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

        for fullDay in selectedDays {
            dataModel.scheduleViewModel.addBlockingEvent(
                name: eventName,
                for: fullDay,
                start: startComponents,
                end: endComponents
            )
        }

        let today = calendar.weekdaySymbols[calendar.component(.weekday, from: Date()) - 1]
        if selectedDays.contains(today) {
            sessionManager.addSession(
                name: eventName,
                selection: dataModel.selection,
                start: startTime,
                end: endTime,
                dayOfWeek: today
            )

            let now = Date()
            if now >= startTime && now <= endTime {
                dataModel.startScheduledBlocking(start: startTime, end: endTime)
            }
        }

        dataModel.scheduleTodayBlockingEvents()

        // Reset fields
        selectedDays.removeAll()
        startTime = Date()
        endTime = Date().addingTimeInterval(3600)
        eventName = ""
    }

}

