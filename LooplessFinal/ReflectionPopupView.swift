import SwiftUI
import UIKit

struct ReflectionPopupView: View {
    var onDismiss: () -> Void

    @State private var selectedReason: String? = nil
    @State private var showThankYou = false
    @State private var fadeOut = false

    private let options = [
        "Just a habit",
        "To escape boredom",
        "To check notifications",
        "To relax mindfully",
        "No real reason"
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if !showThankYou {
                VStack(spacing: 28) {
                    GradientText("Take a moment to reflect")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)

                    Text("Why did you open that app?")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)

                    VStack(spacing: 14) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                Haptics.shared.tap()
                                selectedReason = option
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showThankYou = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    withAnimation {
                                        fadeOut = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        onDismiss()
                                    }
                                }
                            }) {
                                HStack {
                                    Text(option)
                                        .foregroundColor(.white)
                                        .font(.body.weight(.medium))
                                        .padding(.leading, 12)

                                    Spacer()

                                    if selectedReason == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedReason == option ? Color.green.opacity(0.8) : Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button("Cancel & Return") {
                        Haptics.shared.tap()
                        withAnimation {
                            fadeOut = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            onDismiss()
                        }
                    }
                    .foregroundColor(.red)
                    .padding(.top, 12)
                }
                .padding()
                .opacity(fadeOut ? 0 : 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 20) {
                    GradientText("Thank you")
                        .font(.title2.bold())
                        .padding(.bottom, 12)

                    Text("Your response helps us understand your habits.")
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: fadeOut)
    }
}



