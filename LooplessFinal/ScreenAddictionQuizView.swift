//
//  ScreenAddictionQuizView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  ScreenAddictionQuizView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//


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
        VStack(spacing: 20) {
            Text("Screen Addiction Quiz")
                .font(.title.bold())
                .foregroundStyle(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))

            if showResult {
                VStack(spacing: 12) {
                    Text("Your Score: \(score)/\(questions.count)")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text(score == questions.count ? "Excellent awareness!" : "Great effort—review the lessons to boost understanding.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                    Button("Try Again") {
                        currentQuestion = 0
                        score = 0
                        showResult = false
                        selectedAnswer = nil
                        showExplanation = false
                    }
                    .padding()
                    .background(Color.purple)
                    .clipShape(Capsule())
                }
            } else {
                let q = questions[currentQuestion]
                VStack(alignment: .leading, spacing: 16) {
                    Text(q.text)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)

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
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedAnswer != nil {
                                    Image(systemName: i == q.correctIndex ? "checkmark.circle.fill" : (i == selectedAnswer ? "xmark.circle.fill" : "circle"))
                                        .foregroundColor(i == q.correctIndex ? .green : (i == selectedAnswer ? .red : .gray))
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(selectedAnswer != nil)
                    }

                    if showExplanation {
                        Text(q.explanation)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 6)
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
                        .padding()
                        .background(Color.indigo)
                        .clipShape(Capsule())
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [Color.black, Color.indigo.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
} 
