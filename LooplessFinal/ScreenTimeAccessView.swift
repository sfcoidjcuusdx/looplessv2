import SwiftUI
import FamilyControls
import UIKit

struct ScreenTimeAccessView: View {
    var onAuthorized: () -> Void

    @State private var isRequesting = false
    @State private var deniedAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "eye")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.accentColor)

                Text("Screen Time Permission")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("We need permission to monitor your screen time and help you stay focused.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Button(action: {
                    Haptics.shared.tap()
                    requestAuthorization()
                }) {
                    Text("Grant Access")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .alert("Access Denied", isPresented: $deniedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Screen Time access is required to continue.")
            }
        }
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

