//
//  CoreValuesView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  CoreValuesView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//


import SwiftUI

struct CoreValuesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Core Values & Future Self")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text("Clarify your deeper values. Anchor your digital choices in your future self.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal)

                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 12) {
                    Text("🌱 Identity Anchors")
                        .font(.headline)
                    Text("Who do you want to become? Map your identity through actions.")
                        .font(.subheadline)

                    Text("🧭 Value Clarification")
                        .font(.headline)
                    Text("Choose top 3 values: Integrity, Presence, Growth, etc. Write them visibly.")
                        .font(.subheadline)

                    Text("🚀 Future Self Visualization")
                        .font(.headline)
                    Text("Visualize a day in the life of your ideal future self. How do they relate to tech?")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                NavigationLink("Explore Core Values Quiz", destination: CoreValuesQuizView())
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.yellow)
                    .clipShape(Capsule())
            }
            .padding()
        }
        .background(LinearGradient(colors: [.black, .orange.opacity(0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }
}
