//
//  GroundingView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/17/25.
//

import SwiftUI

struct GroundingView: View {
    @ObservedObject var viewModel: BlockerViewModel
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var currentStep = 0
    @State private var responses: [[String]] = Array(repeating: [], count: 5)
    @State private var showExerciseComplete = false
    @State private var showThoughtfulReminder = false
    @State private var isCheckingQuality = false
    @State private var validationMessages: [String] = Array(repeating: "", count: 5)
    @State private var navigateToQuiz = false

    let steps = [
        (icon: "eye.fill", title: "5 Things You See", prompt: "Look around and name:", count: 5, validationKeywords: ["see", "look", "notice", "spot", "observe"]),
        (icon: "hand.tap.fill", title: "4 Things You Feel", prompt: "Notice physical sensations:", count: 4, validationKeywords: ["feel", "touch", "texture", "surface", "contact"]),
        (icon: "ear.fill", title: "3 Sounds You Hear", prompt: "Listen carefully for:", count: 3, validationKeywords: ["hear", "sound", "listen", "noise", "volume"]),
        (icon: "nose.fill", title: "2 Things You Smell", prompt: "Breathe in and identify:", count: 2, validationKeywords: ["smell", "scent", "aroma", "odor", "fragrance"]),
        (icon: "mouth.fill", title: "1 Thing You Taste", prompt: "Focus on your current taste:", count: 1, validationKeywords: ["taste", "flavor", "palate", "aftertaste", "savor"])
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 25) {
                        header
                        progressBar
                        stepCard
                        navigationControls
                        infoBox
                    }
                    .padding(.bottom)
                }

                if showExerciseComplete {
                    completionPopup
                }

                if showThoughtfulReminder {
                    reminderPopup
                }

                NavigationLink(destination: GroundingQuizView(), isActive: $navigateToQuiz) {
                    EmptyView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .foregroundColor(.indigo)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 15) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 44))
                .foregroundColor(.indigo)

            Text("5-4-3-2-1 Grounding")
                .font(.largeTitle.weight(.bold))

            Text("Reduce anxiety by focusing on your senses")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 25)
    }

    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<steps.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? .indigo : (index < currentStep ? .green : .gray.opacity(0.3)))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
    }

    private var stepCard: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: steps[currentStep].icon)
                    .foregroundColor(.indigo)
                Text(steps[currentStep].title)
                    .font(.title2.bold())
                Spacer()
            }

            Text(steps[currentStep].prompt)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(0..<steps[currentStep].count, id: \.self) { index in
                VStack(alignment: .leading, spacing: 4) {
                    TextField("\(index + 1). Describe here...", text: responseBinding(for: index))
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if !validationMessages[index].isEmpty {
                        Text(validationMessages[index])
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }

    private var navigationControls: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    withAnimation { currentStep -= 1 }
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            Button(action: nextStep) {
                if isCheckingQuality {
                    ProgressView()
                } else {
                    Text(currentStep == steps.count - 1 ? "Complete" : "Next")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .disabled(isCheckingQuality)
        }
        .padding(.horizontal)
    }

    private var infoBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Why This Works", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundColor(.indigo)

            Text("This exercise activates your parasympathetic nervous system, lowering stress hormones and anchoring your awareness.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func responseBinding(for index: Int) -> Binding<String> {
        Binding(
            get: {
                if index < responses[currentStep].count {
                    return responses[currentStep][index]
                } else {
                    return ""
                }
            },
            set: { newValue in
                ensureCapacity(for: index)
                responses[currentStep][index] = newValue
                validate(index: index)
            }
        )
    }

    private func ensureCapacity(for index: Int) {
        while responses[currentStep].count <= index {
            responses[currentStep].append("")
        }
    }

    private func validate(index: Int) {
        let text = responses[currentStep][index].lowercased()
        if text.count < 5 {
            validationMessages[index] = "Try to be more specific"
        } else if steps[currentStep].validationKeywords.contains(where: { text.contains($0) }) {
            validationMessages[index] = ""
        } else {
            validationMessages[index] = "Focus on your actual experience"
        }
    }

    private func nextStep() {
        guard validateAll() else {
            withAnimation { showThoughtfulReminder = true }
            return
        }

        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            finish()
        }
    }

    private func validateAll() -> Bool {
        var valid = true
        for index in 0..<steps[currentStep].count {
            ensureCapacity(for: index)
            validate(index: index)
            if !validationMessages[index].isEmpty {
                valid = false
            }
        }
        return valid
    }

    private func finish() {
        isCheckingQuality = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isCheckingQuality = false
            withAnimation {
                showExerciseComplete = true
            }
        }
    }

    private var completionPopup: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)

                    Text("Grounding Complete")
                        .font(.title2.bold())

                    Text("You’ve successfully anchored your attention in the present.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)

                    Button("Take Reflection Quiz") {
                        showExerciseComplete = false
                        navigateToQuiz = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)

                    Button("Back to Techniques") {
                        showExerciseComplete = false
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.indigo)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
                .padding(.horizontal)
            )
    }

    private var reminderPopup: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 20) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.indigo)

                    Text("Be More Specific")
                        .font(.title2.bold())

                    Text("Try to describe your real experience right now. It helps the exercise be more effective.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    Button("I'll Try Again") {
                        showThoughtfulReminder = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
                .padding(.horizontal)
            )
    }
}

