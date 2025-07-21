//
//  BreakingTheLoopView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  BreakingTheLoopView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//


import SwiftUI

struct BreakingTheLoopView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Breaking the Loop: Response Rewiring")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text("Now that you recognize loops, it’s time to rewrite your response pathways with intentional action.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal)

                Image(systemName: "wand.and.stars")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .foregroundColor(.red)

                VStack(alignment: .leading, spacing: 14) {
                    Text("⛔️ The Interrupt")
                        .font(.headline)
                    Text("Before reacting, insert a 5-second pause. Say: ‘Do I really want this?’")
                        .font(.subheadline)

                    Text("🔄 Replace with Routines")
                        .font(.headline)
                    Text("Create replacement behaviors: walk, stretch, breathwork. Make them accessible.")
                        .font(.subheadline)

                    Text("📘 Reflect Regularly")
                        .font(.headline)
                    Text("What worked? What didn’t? Daily journaling increases loop-breaking success.")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                NavigationLink("Practice Response Quiz", destination: LoopBreakingQuizView())
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .clipShape(Capsule())
            }
            .padding()
        }
        .background(LinearGradient(colors: [Color.black, Color.red.opacity(0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }
}
