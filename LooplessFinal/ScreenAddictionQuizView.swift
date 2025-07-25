import SwiftUI

struct ScreenAddictionQuizView: View {
    @State private var currentQuestion = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showExplanation = false
    @State private var score = 0
    @State private var showResult = false

    struct Question {
        let text: String
        let answers: [String]
        let correctIndex: Int
        let explanation: String
    }

    let questions: [Question] = [
        Question(
            text: "What neurotransmitter is most hijacked by apps to keep users engaged?",
            answers: ["Serotonin", "Dopamine", "Oxytocin", "Adrenaline"],
            correctIndex: 1,
            explanation: "Apps are designed to stimulate dopamine release through likes, messages, and unpredictable rewards."
        ),
        Question(
            text: "Which of the following is NOT a feature designed to prolong screen time?",
            answers: ["Infinite scroll", "Push notifications", "Airplane mode", "Autoplay videos"],
            correctIndex: 2,
            explanation: "Airplane mode actually limits screen engagement by disconnecting you from the internet."
        ),
        Question(
            text: "What does attention fragmentation refer to?",
            answers: ["Losing focus due to multitasking", "Splitting screen time between devices", "App crashes", "Short battery life"],
            correctIndex: 0,
            explanation: "Attention fragmentation is caused by constant interruptions and rapid content switching, harming deep focus."
        ),
        Question(
            text: "How does screen overuse affect emotional regulation?",
            answers: ["Improves stress response", "Reduces need for breaks", "Makes discomfort intolerable", "Boosts long-term memory"],
            correctIndex: 2,
            explanation: "Overuse trains the brain to avoid discomfort with stimulation, weakening emotional resilience."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Screen Addiction Quiz")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top)

                if showResult {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Score: \(score)/\(questions.count)")
                            .font(.title2)

                        Text(score == questions.count ? "Excellent awareness!" : "Great effort—review the lessons to boost understanding.")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Button("Try Again") {
                            currentQuestion = 0
                            score = 0
                            showResult = false
                            selectedAnswer = nil
                            showExplanation = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(.top)
                    }
                } else {
                    let q = questions[currentQuestion]

                    VStack(alignment: .leading, spacing: 16) {
                        Text(q.text)
                            .font(.headline)

                        ForEach(q.answers.indices, id: \.self) { i in
                            Button(action: {
                                if selectedAnswer == nil {
                                    selectedAnswer = i
                                    if i == q.correctIndex {
                                        score += 1
                                    }
                                    showExplanation = true
                                }
                            }) {
                                HStack {
                                    Text(q.answers[i])
                                    Spacer()
                                    if selectedAnswer != nil {
                                        Image(systemName: i == q.correctIndex ? "checkmark.circle.fill" : (i == selectedAnswer ? "xmark.circle.fill" : "circle"))
                                            .foregroundColor(i == q.correctIndex ? .green : (i == selectedAnswer ? .red : .gray))
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .disabled(selectedAnswer != nil)
                        }

                        if showExplanation {
                            Text(q.explanation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        if selectedAnswer != nil {
                            Button(currentQuestion == questions.count - 1 ? "Finish" : "Next") {
                                if currentQuestion < questions.count - 1 {
                                    currentQuestion += 1
                                    selectedAnswer = nil
                                    showExplanation = false
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

