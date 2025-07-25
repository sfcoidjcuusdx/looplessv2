import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var viewModel: BlockerViewModel
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel
    @Binding var selectedTab: AppTab
    @Binding var showReflectionPopup: Bool

    @State private var selectedImageName: String? = nil
    @State private var showRewardPopup = false

    @EnvironmentObject var evaluator: RewardsEvaluator

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // 🎁 Reward Grid (using PNGs instead of Lottie)
                    MobiusRewardsGrid(
                        selectedAnimation: $selectedImageName,
                        evaluator: evaluator
                    )
                }
                .padding(.horizontal)
                .padding(.top, 40)
                .onChange(of: evaluator.newlyUnlocked) { newUnlock in
                    if let new = newUnlock {
                        selectedImageName = new
                        showRewardPopup = true
                    }
                }
                .sheet(isPresented: $showRewardPopup, onDismiss: {
                    evaluator.newlyUnlocked = nil
                }) {
                    if let imageName = selectedImageName {
                        RewardPopupView(imageName: imageName)
                    }
                }
                .onAppear {
                    evaluator.evaluateAllGoals()
                    if let new = evaluator.newlyUnlocked {
                        selectedImageName = new
                        showRewardPopup = true
                    }
                }
            }
            .background(Color.white) // White scrollview background
        }
        .background(Color.white.ignoresSafeArea()) // Fullscreen white background
        .fullScreenCover(isPresented: $showReflectionPopup) {
            ReflectionPopupView {
                showReflectionPopup = false
            }
            .navigationBarHidden(true)
        }
    }
}

