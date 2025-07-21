//
//  LoopAwarenessQuizView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  LoopAwarenessQuizView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//

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
        ZStack {
            LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("🌀 Loop Awareness Quiz")
                    .font(.custom("AvenirNext-Bold", size: 24))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.purple, Color.cyan], startPoint: .leading, endPoint: .trailing)
                    )

                if showResult {
                    VStack(spacing: 12) {
                        Text("Quiz Complete")
                            .font(.title2)
                            .foregroundColor(.white)

                        Text("Your score: \(score)/\(questions.count)")
                            .font(.headline)
                            .foregroundColor(.cyan)

                        Button("Retake Quiz") {
                            currentQuestion = 0
                            score = 0
                            showResult = false
                            selectedIndex = nil
                            showExplanation = false
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.indigo)
                        .clipShape(Capsule())
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(questions[currentQuestion].question)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)

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
                                Text(questions[currentQuestion].options[i])
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                selectedIndex == i
                                                    ? (i == questions[currentQuestion].correctIndex ? Color.green.opacity(0.4) : Color.red.opacity(0.4))
                                                    : Color.white.opacity(0.1)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1.2)
                                            )
                                    )
                            }
                            .disabled(selectedIndex != nil) // Disable other answers once selected
                        }

                        if showExplanation {
                            Text(questions[currentQuestion].explanation)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 8)

                            Button("Next") {
                                if currentQuestion + 1 < questions.count {
                                    currentQuestion += 1
                                    showExplanation = false
                                    selectedIndex = nil
                                } else {
                                    showResult = true
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal)
                            .background(Color.cyan)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
}

struct LoopAwarenessQuizView_Previews: PreviewProvider {
    static var previews: some View {
        LoopAwarenessQuizView()
    }
}

