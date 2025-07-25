import SwiftUI

struct LoopMappingExercise: View {
    @State private var selectedTrigger = ""
    @State private var selectedBehavior = ""
    @State private var selectedOutcome = ""

    @State private var triggerConfirmed = false
    @State private var behaviorConfirmed = false
    @State private var outcomeConfirmed = false
    @State private var showSuccessPopup = false

    @AppStorage("savedTrigger") var savedTrigger: String = ""
    @AppStorage("savedBehavior") var savedBehavior: String = ""
    @AppStorage("savedOutcome") var savedOutcome: String = ""

    @Environment(\.dismiss) var dismiss

    let triggers = ["Boredom", "Stress", "Loneliness", "Procrastination", "Habit"]
    let behaviors = ["Open social media", "Scroll endlessly", "Watch videos", "Check notifications", "Play mobile games"]
    let outcomes = ["Time wasted", "Feel guilty", "Miss deadlines", "Lose sleep", "Feel anxious"]

    var personalizedSuggestions: String {
        var suggestions = [String]()

        switch selectedTrigger {
        case "Boredom": suggestions.append("• Add activities to your schedule")
        case "Stress": suggestions.append("• Try the five senses grounding exercise")
        case "Loneliness": suggestions.append("• Message a friend directly instead of scrolling")
        case "Procrastination": suggestions.append("• Try a focus session for productivity")
        case "Habit": suggestions.append("• Block the app and add activities to your schedule")
        default: break
        }

        switch selectedBehavior {
        case "Open social media": suggestions.append("• Message a friend directly instead of passive scrolling")
        case "Scroll endlessly": suggestions.append("• Return to these activities consciously")
        case "Watch videos": suggestions.append("• Use website blockers during work hours")
        case "Check notifications": suggestions.append("• Turn off non-essential notifications")
        case "Play mobile games": suggestions.append("• Delete all games. Schedule healthier replacements")
        default: break
        }

        return suggestions.joined(separator: "\n\n")
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    stepView(
                        title: "1. Select your most common trigger:",
                        pickerItems: triggers,
                        selection: $selectedTrigger,
                        confirmed: $triggerConfirmed,
                        onConfirm: { savedTrigger = selectedTrigger }
                    )

                    if triggerConfirmed {
                        stepView(
                            title: "2. What behavior follows?",
                            pickerItems: behaviors,
                            selection: $selectedBehavior,
                            confirmed: $behaviorConfirmed,
                            onConfirm: { savedBehavior = selectedBehavior }
                        )
                    }

                    if behaviorConfirmed {
                        stepView(
                            title: "3. What's the usual outcome?",
                            pickerItems: outcomes,
                            selection: $selectedOutcome,
                            confirmed: $outcomeConfirmed,
                            onConfirm: { savedOutcome = selectedOutcome }
                        )
                    }

                    if triggerConfirmed && behaviorConfirmed && outcomeConfirmed {
                        resultView
                    }
                }
                .padding()
            }
            .blur(radius: showSuccessPopup ? 5 : 0)

            if showSuccessPopup {
                successPopup
            }
        }
        .navigationTitle("Map Your Loop")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            if !savedTrigger.isEmpty { selectedTrigger = savedTrigger; triggerConfirmed = true }
            if !savedBehavior.isEmpty { selectedBehavior = savedBehavior; behaviorConfirmed = true }
            if !savedOutcome.isEmpty { selectedOutcome = savedOutcome; outcomeConfirmed = true }
        }
    }

    // MARK: - Step View Builder

    func stepView(title: String, pickerItems: [String], selection: Binding<String>, confirmed: Binding<Bool>, onConfirm: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Picker("", selection: selection) {
                ForEach(pickerItems, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 100)

            if !selection.wrappedValue.isEmpty && !confirmed.wrappedValue {
                Button("Confirm") {
                    withAnimation {
                        confirmed.wrappedValue = true
                        onConfirm()
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if confirmed.wrappedValue {
                Text("Selected: \(selection.wrappedValue)")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Result View

    var resultView: some View {
        VStack(spacing: 12) {
            Text("Your Loop Pattern")
                .font(.title3.bold())
                .foregroundColor(.primary)

            Text("\(selectedTrigger) → \(selectedBehavior) → \(selectedOutcome)")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(12)
                .foregroundColor(.orange)
                .font(.body)

            Button("Save & Finish") {
                showSuccessPopup = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Success Popup

    var successPopup: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)

            Text("Great Work!")
                .font(.title2.bold())
                .foregroundColor(.primary)

            Text("You've identified your loop:")
                .font(.body)

            Text("\(selectedTrigger) → \(selectedBehavior) → \(selectedOutcome)")
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                .foregroundColor(.green)

            Text("Try these suggestions:")
                .font(.headline)

            ScrollView {
                Text(personalizedSuggestions)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
            }
            .frame(maxHeight: 160)

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
        .frame(width: 320)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 30)
        .transition(.scale)
    }
}

