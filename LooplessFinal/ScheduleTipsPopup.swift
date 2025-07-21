//
//  ScheduleTipsPopup.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import SwiftUI

struct ScheduleTipsPopup: View {
    @Binding var show: Bool
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // 🔠 Title
                    Text("🧠 Build a Balanced Schedule")
                        .font(.custom("AvenirNext-Bold", size: 26))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    // 📊 Stat-Based Insights
                    VStack(alignment: .leading, spacing: 16) {
                        TipBullet("People who exercise 30+ mins daily are 43% more productive (Harvard Study).")
                        TipBullet("Excess screen time is linked to higher anxiety and lower focus in teens (NIH, 2022).")
                        TipBullet("10–20 minutes of mindfulness daily boosts emotional regulation and decision-making.")
                        TipBullet("Just 15 minutes of reading reduces stress levels by 68% (Univ. of Sussex).")
                        TipBullet("Scheduling intentional breaks can increase your attention span over time.")
                        TipBullet("Replacing late-night screen use with sleep improves memory and mood.")
                    }
                    .font(.custom("AvenirNext-Regular", size: 16))
                    .foregroundColor(.white.opacity(0.85))
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)

                    // ✅ Actionable Tips
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🛠 Tips to Get Started")
                            .font(.custom("AvenirNext-Bold", size: 18))
                            .foregroundColor(.white)

                        TipBullet("Start with 1–2 realistic time blocks per day.")
                        TipBullet("Anchor your screen-free activities to existing habits.")
                        TipBullet("Balance physical, creative, social, and restful activities.")
                        TipBullet("Review your schedule weekly and iterate.")
                    }
                    .font(.custom("AvenirNext-Regular", size: 15))
                    .foregroundColor(.white.opacity(0.9))
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)

                    // 🔘 Continue Button
                    Button(action: {
                        withAnimation {
                            show = false
                            onContinue()
                        }
                    }) {
                        Text("Let’s Start Scheduling")
                            .font(.custom("AvenirNext-Bold", size: 18))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    }
                    .padding(.top)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .padding()
                .shadow(radius: 30)
            }
        }
    }

    // Bullet-style view component
    @ViewBuilder
    func TipBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.custom("AvenirNext-Bold", size: 18))
                .foregroundColor(.purple)
                .padding(.top, 1)

            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

