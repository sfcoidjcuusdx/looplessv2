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
          key: "processing", options: [], autoAdvanceDelay: 3.0, isPassive: true),
    Slide(title: "You may have a moderate or high dependency on your phone.",
          key: "result_summary", options: [], autoAdvanceDelay: 3.0, isPassive: true),
    Slide(title: "Phone dependency can increase health risks like sleep issues and weight gain.",
          key: "health_risks", options: [], autoAdvanceDelay: 3.0, isPassive: true),
    Slide(title: "Mental effects include difficulty making friends and reduced dopamine levels.",
          key: "mental_health", options: [], autoAdvanceDelay: 3.0, isPassive: true)
]

// MARK: - OnboardingSurveyView

struct OnboardingSurveyView: View {
    var onFinished: () -> Void
    @State private var currentSlide = 0
    @State private var responses: [String: String] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
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
        .onAppear { handlePassiveAdvance() }
        .onChange(of: currentSlide) { _ in handlePassiveAdvance() }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
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
        VStack(alignment: .leading, spacing: 16) {
            Text(slide.title)
                .font(.title3)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            if !slide.isPassive {
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
                                .foregroundColor(.primary)

                            Spacer()

                            if response == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGroupedBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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

// MARK: - Preview

#Preview {
    OnboardingSurveyView {
        print("Finished")
    }
}

