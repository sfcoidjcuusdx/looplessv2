//
//  RewardReversalQuizView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  RewardReversalQuizView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//

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
        VStack(spacing: 24) {
            Text("🎯 Reward Reversal Quiz")
                .font(.custom("AvenirNext-Bold", size: 22))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing)
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
                            .background(selectedOption == option ? Color.orange.opacity(0.7) : Color.white.opacity(0.1))
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
                    .fill(LinearGradient(colors: [Color.black, Color.orange.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                    .shadow(radius: 10)
            )
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}

