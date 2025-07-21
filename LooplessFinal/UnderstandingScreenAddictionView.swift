//
//  UnderstandingScreenAddictionView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  UnderstandingScreenAddictionView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//


import SwiftUI

struct UnderstandingScreenAddictionView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Understanding Screen Addiction")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundStyle(
                        LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                    )

                Text("Learn how screens hijack your dopamine system, alter attention, and reshape your habits.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal)

                Image(systemName: "brain.head.profile")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 16) {
                    Text("📈 Dopamine Loops")
                        .font(.headline)
                    Text("Every notification triggers a dopamine spike. Repeated spikes weaken natural motivation and reinforce compulsive checking.")
                        .font(.subheadline)

                    Text("🧠 Attention Fragmentation")
                        .font(.headline)
                    Text("Apps are engineered to fragment focus with infinite scroll, autoplay, and stimuli density.")
                        .font(.subheadline)

                    Text("⚠️ Digital Dependency")
                        .font(.headline)
                    Text("With excessive use, screens replace boredom with stimulation, making the brain avoid discomfort.")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                NavigationLink("Start Quiz", destination: ScreenAddictionQuizView())
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.indigo)
                    .clipShape(Capsule())
                    .padding(.top)
            }
            .padding()
        }
        .background(LinearGradient(colors: [Color.black, Color.indigo.opacity(0.4)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }
}
