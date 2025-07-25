import SwiftUI

struct MobiusRewardCard: View {
    let imageName: String
    let description: String
    let isSelected: Bool
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            if isUnlocked {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 120)
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }

            Text(description)
                .font(.caption)
                .foregroundColor(isUnlocked ? .primary : .gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
        )
    }
}

