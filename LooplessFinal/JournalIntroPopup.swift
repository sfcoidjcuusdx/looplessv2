import SwiftUI

struct JournalIntroPopup: View {
    @Environment(\.dismiss) var dismiss
    @Binding var navigateToJournal: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Why Journal?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Journaling helps you recognize thought patterns, identify emotional triggers, and reflect on your screen usage. It's a core CBT technique to boost awareness and improve habits.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Start Journaling") {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    navigateToJournal = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.background)
        .cornerRadius(20)
        .shadow(radius: 4)
        .padding()
    }
}

