import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: BlockerViewModel
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    @Binding var selectedTab: AppTab
    @Binding var showReflectionPopup: Bool

    @State private var selectedAnimation: String? = nil
    @State private var showRewardPopup = false
    @StateObject private var healthManager = HealthIndexManager()

    @EnvironmentObject var evaluator: RewardsEvaluator

    var body: some View {
        ZStack {
            // 🌌 Animated Opal-style background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.15), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            NavigationStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 36) {
                        // 🧠 Main Title
                        Text("Mobius Rewards")
                            .font(.custom("AvenirNext-Bold", size: 34))
                            .foregroundStyle(
                                LinearGradient(colors: [.cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .multilineTextAlignment(.center)
                            .padding(.top, 40)
                            .shadow(color: .cyan.opacity(0.35), radius: 4, x: 0, y: 2)

                        // 🎁 Grid of Reward Cards
                        MobiusRewardsGrid(
                            selectedAnimation: $selectedAnimation,
                            evaluator: evaluator
                        )
                    }
                    .padding(.horizontal, 24)
                    .onChange(of: evaluator.newlyUnlocked) { newUnlock in
                        print("🎉 evaluator.newlyUnlocked triggered: \(String(describing: newUnlock))")
                        if let new = newUnlock {
                            selectedAnimation = new
                            showRewardPopup = true
                        }
                    }
                    .sheet(isPresented: $showRewardPopup, onDismiss: {
                        evaluator.newlyUnlocked = nil  // 👈 Reset after showing popup
                    }) {
                        if let anim = selectedAnimation {
                            RewardPopupView(animationName: anim)
                        }
                    }

                }
                .onAppear {
                    print("🟢 Calling evaluator.evaluateAllGoals from GoalsView: \(Unmanaged.passUnretained(evaluator).toOpaque())")
                    evaluator.evaluateAllGoals()
                    
                    if let new = evaluator.newlyUnlocked {
                        selectedAnimation = new
                        showRewardPopup = true
                    }
                }


            }

            // 🌿 Reflection Overlay
            if showReflectionPopup {
                Color.black.opacity(0.4).ignoresSafeArea()
                ReflectionPopupView {
                    showReflectionPopup = false
                }
                .frame(maxWidth: 350)
                .padding()
                .transition(.scale)
                .zIndex(1)
            }
        }
    }
}

