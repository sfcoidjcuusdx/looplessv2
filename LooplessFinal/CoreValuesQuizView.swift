import SwiftUI

struct CoreValuesQuizView: View {
    @State private var currentQuestion = 0
    @State private var showExplanation = false
    @State private var selectedOption: String? = nil
    @State private var quizComplete = false

    struct Question {
        let text: String
        let options: [String]
        let correctAnswer: String
        let explanation: String
    }

    let questions: [Question] = [
        Question(
            text: "Why are core values important in recovery?",
            options: ["They control your urges", "They align actions with purpose", "They make you feel guilty", "They limit technology usage"],
            correctAnswer: "They align actions with purpose",
            explanation: "Core values give direction to your decisions and help you act with intention."
        ),
        Question(
            text: "Which of these is an example of a core value?",
            options: ["Checking social media", "Discipline", "Scrolling endlessly", "Liking every post"],
            correctAnswer: "Discipline",
            explanation: "Discipline is a value that supports long-term goals over short-term urges."
        ),
        Question(
            text: "How do values help disrupt a behavioral loop?",
            options: ["They create shame", "They justify dopamine use", "They offer a 'why' for changing habits", "They make tech more fun"],
            correctAnswer: "They offer a 'why' for changing habits",
            explanation: "Having a strong 'why' increases motivation to sustain meaningful change."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Core Values Quiz")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top)

                if quizComplete {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You've completed the quiz.")
                            .font(.title2)

                        Button("Restart Quiz") {
                            currentQuestion = 0
                            selectedOption = nil
                            showExplanation = false
                            quizComplete = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(.top)
                    }
                } else {
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

                                Button("Next") {
                                    if currentQuestion + 1 < questions.count {
                                        currentQuestion += 1
                                        showExplanation = false
                                        selectedOption = nil
                                    } else {
                                        quizComplete = true
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.large)
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

