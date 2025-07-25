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
            Color(.systemBackground).ignoresSafeArea() // native white background

            if !showThankYou {
                VStack(spacing: 24) {
                    Text("Take a moment to reflect")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text("Why did you open that app?")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
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
                                        .foregroundColor(.primary)
                                        .font(.body.weight(.medium))

                                    Spacer()

                                    if selectedReason == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    Color.white
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
                    Text("Thank you")
                        .font(.title2.bold())
                        .padding(.bottom, 12)

                    Text("Your response helps us understand your habits.")
                        .foregroundColor(.secondary)
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

