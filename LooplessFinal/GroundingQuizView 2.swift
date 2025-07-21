//
//  GroundingQuizView 2.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/17/25.
//


//
//  GroundingQuizView.swift
//  loopless
//
//


import SwiftUI

struct GroundingQuizView: View {
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var showExercise = false // New state for navigation

    let questions: [GroundingQuestion] = [
        GroundingQuestion(prompt: "What is the purpose of the 5-4-3-2-1 grounding technique?",
                           options: ["To fall asleep faster", "To return to the present moment", "To distract from tasks", "To improve memory"],
                           correctIndex: 1,
                           explanation: "The grounding technique is used to calm the nervous system and bring awareness back to the present moment."),

        GroundingQuestion(prompt: "Which sense is associated with naming five things in the 5-4-3-2-1 method?",
                           options: ["Touch", "Taste", "Sight", "Sound"],
                           correctIndex: 2,
                           explanation: "The technique starts with identifying five things you can see."),

        GroundingQuestion(prompt: "Why does engaging your senses help reduce anxiety?",
                           options: ["It increases adrenaline", "It activates your imagination", "It calms the amygdala", "It improves posture"],
                           correctIndex: 2,
                           explanation: "Sensory engagement can calm the brain’s threat response system and reduce anxiety."),

        GroundingQuestion(prompt: "Which of these is a good example of grounding through touch?",
                           options: ["Listening to music", "Noticing the texture of your clothes", "Tasting peppermint", "Watching people pass by"],
                           correctIndex: 1,
                           explanation: "Noticing texture or pressure on your body is a tactile (touch) grounding technique.")
    ]

    var body: some View {
        VStack(spacing: 28) {
            Text("🌿 Grounding Quiz")
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .leading, endPoint: .trailing))

            if showResult {
                VStack(spacing: 12) {
                    Text("You scored \(score) out of \(questions.count)")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(score == questions.count ? "Perfect grounding awareness! 🌟" : "Well done! Keep practicing.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))

                    Button("Retake Quiz") {
                        currentQuestion = 0
                        score = 0
                        showResult = false
                    }
                    .padding()
                    .background(Color.mint)
                    .clipShape(Capsule())
                    .foregroundColor(.black)
                    Button("Take Exercise") {
                                                showExercise = true
                                            }
                    .padding()
                                           .background(Color.teal)
                                           .clipShape(Capsule())
                                           .foregroundColor(.black)
                }
                
            } else {
                let question = questions[currentQuestion]

                VStack(alignment: .leading, spacing: 12) {
                    Text("Q\(currentQuestion + 1). \(question.prompt)")
                        .font(.headline)
                        .foregroundColor(.white)

                    ForEach(0..<question.options.count, id: \ .self) { index in
                        Button(action: {
                            if index == question.correctIndex {
                                score += 1
                            }

                            withAnimation {
                                if currentQuestion + 1 < questions.count {
                                    currentQuestion += 1
                                } else {
                                    showResult = true
                                }
                            }
                        }) {
                            Text(question.options[index])
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundColor(.white)
                                .shadow(radius: 1)
                        }
                    }

                    Text("\u{1F4AC} \(question.explanation)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 4)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(LinearGradient(colors: [.black, .teal.opacity(0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
        .fullScreenCover(isPresented: $showExercise) {
                   GroundingView(
                       viewModel: BlockerViewModel(),
                       scheduleViewModel: ScheduleViewModel()
                   )
               }
    }
}

struct GroundingQuestion {
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
} 
