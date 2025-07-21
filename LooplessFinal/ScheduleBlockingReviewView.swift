import SwiftUI

struct ScheduleBlockingView: View {
    @EnvironmentObject var dataModel: LooplessDataModel
    @EnvironmentObject var sessionManager: BlockingSessionManager

    @State private var selectedDays: Set<String> = []
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var eventName: String = ""
    @State private var showingAlert = false

    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Title
                        GradientText("Create Blocking Session")
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)

                        // Event name
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Event Name")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline.weight(.medium))

                            TextField("e.g. Deep Work", text: $eventName)
                                .padding(12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .font(.system(size: 16, design: .rounded))
                        }

                        // Days row
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Days")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline.weight(.medium))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                                ForEach(days, id: \.self) { day in
                                    let isSelected = selectedDays.contains(day)
                                    Button(action: {
                                        if isSelected {
                                            selectedDays.remove(day)
                                        } else {
                                            selectedDays.insert(day)
                                        }
                                        Haptics.shared.tap()
                                    }) {
                                        Text(day)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(isSelected ? .black : .white)
                                            .frame(width: 32, height: 32)
                                            .background(isSelected ? Color.white : Color.white.opacity(0.05))
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }


                        // Time pickers
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select Time Interval")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline.weight(.medium))

                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Start")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                        .colorScheme(.dark)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("End")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                        .colorScheme(.dark)
                                }
                            }
                        }

                        // Confirm button
                        Button(action: handleConfirm) {
                            Text("Confirm & Apply")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [Color.green.opacity(0.9), Color.mint.opacity(0.8)],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                    .frame(width: geo.size.width * 0.94) // ✅ Constraint to screen width
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Missing Information"),
                    message: Text("Please fill all fields and select a valid time range."),
                    dismissButton: .default(Text("OK"))
                )
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

        for day in selectedDays {
            dataModel.scheduleViewModel.addBlockingEvent(
                name: eventName,
                for: fullDayName(from: day),
                start: startComponents,
                end: endComponents
            )
        }

        let today = calendar.weekdaySymbols[calendar.component(.weekday, from: Date()) - 1]
        if selectedDays.contains(String(today.prefix(3))) {
            sessionManager.addSession(
                name: eventName,
                selection: dataModel.selection,
                start: startTime,
                end: endTime,
                dayOfWeek: today
            )
        }

        selectedDays.removeAll()
        startTime = Date()
        endTime = Date().addingTimeInterval(3600)
        eventName = ""
    }

    private func fullDayName(from short: String) -> String {
        switch short {
        case "Mon": return "Monday"
        case "Tue": return "Tuesday"
        case "Wed": return "Wednesday"
        case "Thu": return "Thursday"
        case "Fri": return "Friday"
        case "Sat": return "Saturday"
        case "Sun": return "Sunday"
        default: return short
        }
    }
}



