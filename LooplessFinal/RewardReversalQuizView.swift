import SwiftUI

struct RewardReversalQuizView: View {
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
            text: "What is 'reward reversal'?",
            options: ["Removing rewards altogether", "Using rewards to reinforce bad habits", "Reframing or replacing a reward with a healthier one", "Punishing yourself for screen time"],
            correctAnswer: "Reframing or replacing a reward with a healthier one",
            explanation: "Reward reversal is about redirecting your brain to crave healthier reinforcement."
        ),
        Question(
            text: "Which of the following is a reward reversal example?",
            options: ["Watching Netflix after 5 hours of study", "Using social media during work breaks", "Taking a walk instead of endless scrolling", "Binge-eating as a reward"],
            correctAnswer: "Taking a walk instead of endless scrolling",
            explanation: "The goal is to satisfy the brain's craving with a healthier, intentional action."
        ),
        Question(
            text: "Why is it important to consciously choose your reward?",
            options: ["To gain more followers", "To train the loop to expect better payoffs", "To punish the impulse", "To make things boring"],
            correctAnswer: "To train the loop to expect better payoffs",
            explanation: "Intentionally chosen rewards guide your brain toward sustained motivation."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Reward Reversal Quiz")
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

