//
//  CoreValuesQuizView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  CoreValuesQuizView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//

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
        VStack(spacing: 24) {
            Text("💡 Core Values Quiz")
                .font(.custom("AvenirNext-Bold", size: 22))
                .foregroundStyle(
                    LinearGradient(colors: [.mint, .blue], startPoint: .leading, endPoint: .trailing)
                )

            if quizComplete {
                VStack(spacing: 12) {
                    Text("🎉 You've completed the quiz!")
                        .font(.title2)
                        .foregroundColor(.white)

                    Button("Restart Quiz") {
                        currentQuestion = 0
                        selectedOption = nil
                        showExplanation = false
                        quizComplete = false
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.mint)
                    .clipShape(Capsule())
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text(questions[currentQuestion].text)
                        .font(.headline)
                        .foregroundColor(.white)

                    ForEach(questions[currentQuestion].options, id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                            showExplanation = true
                        }) {
                            Text(option)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedOption == option ? Color.green.opacity(0.6) : Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                    }

                    if showExplanation, let selected = selectedOption {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(selected == questions[currentQuestion].correctAnswer ? "✅ Correct!" : "❌ Incorrect")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(questions[currentQuestion].explanation)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))

                            Button("Next") {
                                if currentQuestion + 1 < questions.count {
                                    currentQuestion += 1
                                    showExplanation = false
                                    selectedOption = nil
                                } else {
                                    quizComplete = true
                                }
                            }
                            .padding(.top)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(colors: [Color.black, Color.green.opacity(0.6)],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                        .shadow(radius: 10)
                )
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}

