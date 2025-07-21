import SwiftUI
import FamilyControls
import UIKit

struct ScreenTimeAccessView: View {
    var onAuthorized: () -> Void

    @State private var isRequesting = false
    @State private var deniedAlert = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "eye") // Subtler than hand.raised
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.mint.opacity(0.85))

                GradientText("Screen Time Permission")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("We need permission to monitor your screen time and help you stay focused.")
                    .font(.body.weight(.medium))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button(action: {
                    Haptics.shared.tap()
                    requestAuthorization()
                }) {
                    Text("Grant Access")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.mint.opacity(0.9), .cyan.opacity(0.8)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
        }
        .alert("Access Denied", isPresented: $deniedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Screen Time access is required to continue.")
        }
        .preferredColorScheme(.dark)
    }

    private func requestAuthorization() {
        isRequesting = true
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                isRequesting = false

                if AuthorizationCenter.shared.authorizationStatus == .approved {
                    Haptics.shared.tap()
                    onAuthorized()
                } else {
                    Haptics.shared.tap()
                    deniedAlert = true
                }
            } catch {
                isRequesting = false
                Haptics.shared.tap()
                deniedAlert = true
            }
        }
    }
}

