import SwiftUI
import Lottie

struct MobiusRewardCard: View {
    let animationName: String
    let description: String
    let isSelected: Bool
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            if isUnlocked {
                LottieView(animationName: animationName, loopMode: .loop)
                    .frame(height: 120)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 120)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.gray)
                }
            }

            Text(description)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 2)
        )
    }
}

