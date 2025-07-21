import SwiftUI

struct MobiusRewardsGrid: View {
    @Binding var selectedAnimation: String?
    @ObservedObject var evaluator: RewardsEvaluator

    let mobiusAnimations: [(name: String, description: String)] = [
        ("Animation - 1750346740240", "🎁 Invited 1 Friend"),
        ("Animation - 1750346749420", "🎉 Invited 3 Friends"),
        ("Animation - 1750346749523", "✅ Completed 1 Blocking Session"),
        ("Animation - 1750346766971", "🏅 Completed 5 Blocking Sessions"),
        ("Animation - 1750346774873", "🏆 Completed 10 Blocking Sessions"),
        ("Animation - 1750346785425", "🎖 Completed 15 Blocking Sessions")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
     

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                ForEach(mobiusAnimations, id: \.name) { animation in
                    let unlocked = evaluator.isUnlocked(animation.name)

                    VStack(spacing: 12) {
                        if unlocked {
                            LottieView(animationName: animation.name, loopMode: .loop)
                                .frame(height: 120)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.15))
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 120)
                        }

                        Spacer(minLength: 0)

                        Text(animation.description)
                            .font(.custom("AvenirNext-Medium", size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(unlocked ? 0.95 : 0.5))
                            .padding(.horizontal, 6)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 180) // ✅ Enforces uniform card height
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: unlocked ? [.cyan, .purple] : [.gray.opacity(0.2), .gray.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.4
                                    )
                            )
                            .shadow(color: unlocked ? Color.cyan.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
                    )
                    .onTapGesture {
                        if unlocked {
                            withAnimation(.easeInOut) {
                                selectedAnimation = (selectedAnimation == animation.name) ? nil : animation.name
                            }
                        }
                    }
                }
            }
        }
    }
}

