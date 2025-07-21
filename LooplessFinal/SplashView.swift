import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool
    @State private var animateLogo = false
    @State private var progressWidth: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Image("LOGO 2-2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .scaleEffect(animateLogo ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.2).repeatCount(1, autoreverses: true), value: animateLogo)

                // Fake cyan progress bar
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(height: 6)
                        .foregroundColor(.white.opacity(0.1))

                    Capsule()
                        .frame(width: progressWidth, height: 6)
                        .foregroundColor(.cyan)
                        .animation(.easeInOut(duration: 4.5), value: progressWidth)
                }
                .padding(.horizontal, 60)
            }
        }
        .onAppear {
            animateLogo = true
            progressWidth = UIScreen.main.bounds.width - 120

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                isFinished = true
            }
        }
    }
}

