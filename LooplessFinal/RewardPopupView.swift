import SwiftUI
import Lottie

struct RewardPopupView: View {
    var animationName: String

    var body: some View {
        VStack(spacing: 24) {
            Text("🎉 Reward Unlocked!")
                .font(.title)
                .foregroundColor(.white)

            LottieView(animationName: animationName, loopMode: .loop)
                .frame(height: 200)

            Text("Keep up the good work!")
                .foregroundColor(.white.opacity(0.8))

            Button("Close") {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
            }
            .padding()
            .background(Color.cyan.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors: [.black, .gray], startPoint: .top, endPoint: .bottom))
                .shadow(radius: 10)
        )
        .padding()
    }
}

