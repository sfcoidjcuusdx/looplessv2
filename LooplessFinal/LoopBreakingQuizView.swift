//
//  LoopBreakingQuizView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  LoopBreakingQuizView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//

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
        VStack(spacing: 24) {
            Text("🧠 Loop Breaking Quiz")
                .font(.custom("AvenirNext-Bold", size: 22))
                .foregroundStyle(
                    LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                )

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
                            .background(selectedOption == option ? Color.blue.opacity(0.7) : Color.white.opacity(0.1))
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

                        if currentQuestion + 1 < questions.count {
                            Button("Next") {
                                currentQuestion += 1
                                showExplanation = false
                                selectedOption = nil
                            }
                            .padding(.top)
                        } else {
                            Text("🎉 You've completed the quiz!")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding(.top)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [Color.black, Color.indigo.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                    .shadow(radius: 10)
            )
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}

