import SwiftUI

struct RewardPopupView: View {
    var imageName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Reward Unlocked")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 10)

            Text("Keep up the good work!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                dismiss()
            }) {
                Text("Close")
                    .font(.headline)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding()
    }
}

