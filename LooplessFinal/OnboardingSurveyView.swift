import SwiftUI
import UIKit

// MARK: - Slide Model

struct Slide {
    let title: String
    let key: String
    let options: [String]
    let autoAdvanceDelay: TimeInterval
    let isPassive: Bool
}

// MARK: - Slide Data

let slides: [Slide] = [
    Slide(title: "At what age did you notice yourself becoming increasingly reliant on your iPhone?",
          key: "age_started", options: ["< 13", "13–18", "19–30", "30+"], autoAdvanceDelay: 0.3, isPassive: false),
    Slide(title: "Which apps do you find yourself relying on the most?",
          key: "apps", options: ["Instagram", "TikTok", "YouTube", "Snapchat", "Twitter", "Other"], autoAdvanceDelay: 0.3, isPassive: false),
    Slide(title: "How much time do you estimate you spend on the selected apps?",
          key: "estimated_time", options: ["30 min or less", "30 min – 1 hr", "1 – 3 hrs", "3+ hrs"], autoAdvanceDelay: 0.3, isPassive: false),
    Slide(title: "Has your reliance on your mobile device increased over time?",
          key: "increase", options: ["Yes", "No"], autoAdvanceDelay: 0.3, isPassive: false),
    Slide(title: "How old are you?",
          key: "age_group", options: ["< 13", "13–18", "19–30", "30+"], autoAdvanceDelay: 0.3, isPassive: false),
    Slide(title: "How often does your phone distract from more meaningful uses of time?",
          key: "distraction_freq", options: ["Frequently", "Occasionally", "Rarely or never"], autoAdvanceDelay: 0.3, isPassive: false),
    Slide(title: "What emotion are you most likely to feel when you open these apps?",
          key: "emotion", options: ["Excited", "Bored", "Lonely", "Anxious", "Relaxed"], autoAdvanceDelay: 0.3, isPassive: false),
    Slide(title: "Would you be interested in supplemental resources to help reduce screen time?",
          key: "supplemental_interest", options: ["Yes", "No"], autoAdvanceDelay: 0.3, isPassive: false),
    Slide(title: "Do you think phone use negatively impacts your relationships?",
          key: "relationship_impact", options: ["Yes", "No"], autoAdvanceDelay: 0.3, isPassive: false),
    Slide(title: "Do you turn to these apps out of boredom?",
          key: "boredom", options: ["Frequently", "Occasionally", "Rarely or never"], autoAdvanceDelay: 0.3, isPassive: false),
    Slide(title: "Analyzing your answers to build a custom screen-time plan...",
          key: "processing", options: [], autoAdvanceDelay: 4.0, isPassive: true),
    Slide(title: "You may have a moderate or high dependency on your phone.",
          key: "result_summary", options: [], autoAdvanceDelay: 5.0, isPassive: true),
    Slide(title: "Phone dependency can increase health risks like sleep issues and weight gain.",
          key: "health_risks", options: [], autoAdvanceDelay: 5.0, isPassive: true),
    Slide(title: "Mental effects include difficulty making friends and reduced dopamine levels.",
          key: "mental_health", options: [], autoAdvanceDelay: 5.0, isPassive: true)
]

// MARK: - Onboarding View

struct OnboardingSurveyView: View {
    var onFinished: () -> Void
    @State private var currentSlide = 0
    @State private var responses: [String: String] = [:]
    @State private var fadeIn = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                SlideView(
                    slide: slides[currentSlide],
                    response: $responses[slides[currentSlide].key],
                    onOptionSelected: {
                        if currentSlide < slides.count - 1 {
                            currentSlide += 1
                        } else {
                            onFinished()
                        }
                    }
                )
            }
            .padding()
            .opacity(fadeIn ? 1 : 0)
            .animation(.easeInOut(duration: 0.8), value: fadeIn)
            .onAppear {
                fadeIn = true
                handlePassiveAdvance()
            }
            .onChange(of: currentSlide) { _ in
                handlePassiveAdvance()
            }
        }
    }

    private func handlePassiveAdvance() {
        let slide = slides[currentSlide]
        if slide.isPassive {
            DispatchQueue.main.asyncAfter(deadline: .now() + slide.autoAdvanceDelay) {
                responses[slide.key] = "auto"
                if currentSlide < slides.count - 1 {
                    currentSlide += 1
                } else {
                    onFinished()
                }
            }
        }
    }
}

// MARK: - SlideView

struct SlideView: View {
    let slide: Slide
    @Binding var response: String?
    let onOptionSelected: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            GradientText(slide.title)
                .font(.title3.bold())
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            if !slide.isPassive {
                VStack(spacing: 16) {
                    ForEach(slide.options, id: \.self) { option in
                        Button(action: {
                            Haptics.shared.tap()
                            response = option
                            DispatchQueue.main.asyncAfter(deadline: .now() + slide.autoAdvanceDelay) {
                                onOptionSelected()
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(.white)
                                    .font(.body.weight(.medium))
                                    .padding(.leading, 12)

                                Spacer()

                                if response == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(response == option ? Color.green.opacity(0.8) : Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - GradientText

struct GradientText: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundStyle(
                LinearGradient(colors: [Color.cyan.opacity(0.8), Color.white],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
    }

    init(_ text: String) {
        self.text = text
    }
}

// MARK: - Haptics

class Haptics {
    static let shared = Haptics()
    private let generator = UIImpactFeedbackGenerator(style: .light)

    func tap() {
        generator.impactOccurred()
    }
}

#Preview {
    OnboardingSurveyView {
        print("Finished")
    }
}

