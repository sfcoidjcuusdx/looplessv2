//
//  LoopImpulseAwarenessView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  LoopImpulseAwarenessView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//


import SwiftUI

struct LoopImpulseAwarenessView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("The Loop & Impulse Awareness")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundStyle(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))

                Text("Learn to identify the automatic triggers, impulses, and app loops that drive your compulsive usage.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal)

                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 12) {
                    Text("🔥 Trigger Awareness")
                        .font(.headline)
                    Text("What situations, emotions, or times of day lead to screen use? Track them over a week.")
                        .font(.subheadline)

                    Text("🧭 Loop Patterns")
                        .font(.headline)
                    Text("A loop often looks like: boredom → unlock phone → TikTok → regret → repeat. Map your top 3.")
                        .font(.subheadline)

                    Text("🎯 Impulse Journal")
                        .font(.headline)
                    Text("Write down each time you feel the urge to open an app. Did you act? What triggered it?")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                NavigationLink("Quiz Your Loops", destination: LoopAwarenessQuizView())
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
            .padding()
        }
        .background(LinearGradient(colors: [.black, .orange.opacity(0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }
}
