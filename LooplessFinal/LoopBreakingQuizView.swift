import SwiftUI

struct LoopBreakingQuizView: View {
    @State private var currentQuestion = 0
    @State private var showExplanation = false
    @State private var selectedOption: String? = nil

    struct Question {
        let text: String
        let options: [String]
        let correctAnswer: String
        let explanation: String
    }

    let questions: [Question] = [
        Question(
            text: "What is the first step in breaking a behavioral loop?",
            options: ["Avoid all technology", "Recognize the cue", "Delete all social media", "Take a nap"],
            correctAnswer: "Recognize the cue",
            explanation: "Identifying the cue that triggers the loop is the foundation for breaking it."
        ),
        Question(
            text: "Which of these is an effective loop-breaking strategy?",
            options: ["Disabling notifications", "Checking your phone more often", "Ignoring urges", "Staying busy 24/7"],
            correctAnswer: "Disabling notifications",
            explanation: "Minimizing cues, like disabling notifications, reduces loop reinforcement."
        ),
        Question(
            text: "Why is mindfulness important in breaking loops?",
            options: ["It helps you multitask", "It increases impulsivity", "It builds awareness", "It boosts dopamine"],
            correctAnswer: "It builds awareness",
            explanation: "Mindfulness helps you notice patterns and pause before acting automatically."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Loop Breaking Quiz")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 16) {
                    Text(questions[currentQuestion].text)
                        .font(.headline)

                    ForEach(questions[currentQuestion].options, id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                            showExplanation = true
                        }) {
                            HStack {
                                Text(option)
                                Spacer()
                                if showExplanation && selectedOption == option {
                                    Image(systemName: option == questions[currentQuestion].correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(option == questions[currentQuestion].correctAnswer ? .green : .red)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .disabled(showExplanation)
                    }

                    if showExplanation, let selected = selectedOption {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(selected == questions[currentQuestion].correctAnswer ? "Correct" : "Incorrect")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(selected == questions[currentQuestion].correctAnswer ? .green : .red)

                            Text(questions[currentQuestion].explanation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if currentQuestion + 1 < questions.count {
                                Button("Next") {
                                    currentQuestion += 1
                                    showExplanation = false
                                    selectedOption = nil
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                                .padding(.top)
                            } else {
                                Text("You've completed the quiz.")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.accentColor)
                                    .padding(.top)
                            }
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

