import SwiftUI

struct LoopAwarenessQuizView: View {
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var showExplanation = false
    @State private var selectedIndex: Int? = nil

    let questions: [(question: String, options: [String], correctIndex: Int, explanation: String)] = [
        ("What is a common trigger for entering a screen time loop?",
         ["Hunger", "Boredom", "Exercise", "Cold weather"],
         1,
         "Boredom is a major emotional cue that often leads to mindless scrolling or app switching."),

        ("How can you become more aware of your app use patterns?",
         ["Use Screen Time analytics", "Guess based on feeling", "Ask friends", "None of the above"],
         0,
         "Using built-in analytics like Screen Time or Loopless charts can make unconscious patterns visible."),

        ("Why is identifying loops important?",
         ["To feel guilty", "To limit joy", "To break unhealthy patterns", "To compare with others"],
         2,
         "The purpose is to help break repetitive and harmful habits, not to induce shame."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Loop Awareness Quiz")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top)

                if showResult {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quiz Complete")
                            .font(.title2)

                        Text("Your score: \(score)/\(questions.count)")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Button("Retake Quiz") {
                            currentQuestion = 0
                            score = 0
                            showResult = false
                            selectedIndex = nil
                            showExplanation = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(.top)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(questions[currentQuestion].question)
                            .font(.headline)

                        ForEach(0..<questions[currentQuestion].options.count, id: \.self) { i in
                            Button(action: {
                                if selectedIndex == nil {
                                    selectedIndex = i
                                    showExplanation = true
                                    if i == questions[currentQuestion].correctIndex {
                                        score += 1
                                    }
                                }
                            }) {
                                HStack {
                                    Text(questions[currentQuestion].options[i])
                                    Spacer()
                                    if selectedIndex != nil {
                                        Image(systemName: i == questions[currentQuestion].correctIndex ? "checkmark.circle.fill" : (i == selectedIndex ? "xmark.circle.fill" : "circle"))
                                            .foregroundColor(i == questions[currentQuestion].correctIndex ? .green : (i == selectedIndex ? .red : .gray))
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .disabled(selectedIndex != nil)
                        }

                        if showExplanation {
                            Text(questions[currentQuestion].explanation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top)

                            Button(currentQuestion + 1 < questions.count ? "Next" : "Finish") {
                                if currentQuestion + 1 < questions.count {
                                    currentQuestion += 1
                                    showExplanation = false
                                    selectedIndex = nil
                                } else {
                                    showResult = true
                                }
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            .padding(.top)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Quiz")
        .background(Color(.systemBackground))
    }
}

