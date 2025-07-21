import SwiftUI

struct TherapyScreenView: View {
    @Binding var selectedTab: AppTab
    @Binding var showReflectionPopup: Bool
    @State private var showJournalIntro = false
    @State private var navigateToJournal = false
    @StateObject var blockerViewModel = BlockerViewModel()
    @StateObject var scheduleViewModel = ScheduleViewModel()
    @State private var visionBoard: VisionBoard? = nil
    @State private var showVisionBoardFullScreen = false
    @State private var rewardChecks: [RewardRealityCheckActivity.RewardCheck] = []

    @AppStorage("savedTrigger") private var savedTrigger: String = ""
    @AppStorage("savedBehavior") private var savedBehavior: String = ""
    @AppStorage("savedOutcome") private var savedOutcome: String = ""

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        header
                        visionBoardSection
                        loopMappingSection
                        rewardReversalSection
                        featuredLesson
                        lessonList
                        journalButton
                    }
                    .padding(.bottom, 32)
                }
                .background(Color.black.ignoresSafeArea())
                .sheet(isPresented: $showVisionBoardFullScreen) {
                    if let board = visionBoard {
                        VisionBoardView(
                            values: board.values,
                            description: board.description,
                            currentHabits: board.currentHabits,
                            idealHabits: board.idealHabits
                        )
                    }
                }
                .sheet(isPresented: $showJournalIntro) {
                    JournalIntroPopup(navigateToJournal: $navigateToJournal)
                }
                .navigationDestination(isPresented: $navigateToJournal) {
                    JournalView()
                }
            }

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
        .onAppear {
            loadVisionBoard()
            loadRewardChecks()
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Text("📚 Therapy Lessons")
                .font(.title2.bold())
                .foregroundStyle(
                    LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                )
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
    }


    struct VisionBoardPreview: View {
        let values: [String]
        let description: String
        let currentHabits: [String]
        let idealHabits: [String]
        
        var body: some View {
            VStack(spacing: 0) {
                // Values
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(values.prefix(5), id: \.self) { value in
                            Text(value)
                                .font(.caption.bold())
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.purple.opacity(0.2))
                                .cornerRadius(20)
                                .foregroundColor(.purple)
                        }
                    }
                }
                .padding(.bottom, 12)
                
                // Description excerpt
                Text(description.prefix(140) + (description.count > 140 ? "..." : ""))
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
                    .padding(.bottom, 12)
                
                // Habit transformation example
                if let current = currentHabits.first, let ideal = idealHabits.first {
                    HStack {
                        Text(current)
                            .font(.caption)
                            .strikethrough()
                            .padding(6)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(6)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.purple)
                        
                        Text(ideal)
                            .font(.caption.bold())
                            .padding(6)
                            .background(Color.purple.opacity(0.2))
                            .cornerRadius(6)
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    private var visionBoardSection: some View {
        Group {
            if let board = visionBoard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Your Digital Wellbeing Vision")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Button("Expand") {
                            showVisionBoardFullScreen = true
                        }
                        .font(.caption.bold())
                        .foregroundColor(.purple)
                    }
                    .padding(.horizontal)

                    VisionBoardPreview(
                        values: board.values,
                        description: board.description,
                        currentHabits: board.currentHabits,
                        idealHabits: board.idealHabits
                    )
                    .padding(.horizontal)
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Design Your Digital Future")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Text("Create a vision board to guide your relationship with technology")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    NavigationLink(destination: FutureSelfVisionActivity()) {
                        Text("Create Vision Board")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }

    private var loopMappingSection: some View {
        Group {
            if !savedTrigger.isEmpty && !savedBehavior.isEmpty && !savedOutcome.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Your Behavior Loop")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Spacer()
                        NavigationLink(destination: LoopMappingExercise()) {
                            Text("Edit")
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(savedTrigger) → \(savedBehavior) → \(savedOutcome)")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Map Your Behavior Patterns")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Text("Identify your trigger-behavior-outcome loops to gain awareness")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    NavigationLink(destination: LoopMappingExercise()) {
                        Text("Map Your Loop")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }

    struct RewardReversalPreview: View {
        let check: RewardRealityCheckActivity.RewardCheck
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(check.habit)
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text(check.lastEdited.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let firstReward = check.perceivedRewards.first,
                   let firstCost = check.actualCosts.first,
                   let firstAlternative = check.betterAlternatives.first {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "arrow.down.right")
                                .foregroundColor(.blue)
                            Text(firstReward)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        
                        HStack {
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.red)
                            Text(firstCost)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        
                        HStack {
                            Image(systemName: "arrow.uturn.up")
                                .foregroundColor(.green)
                            Text(firstAlternative)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        )}
    }
    private var rewardReversalSection: some View {
        Group {
            if !rewardChecks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Your Reward Reversals")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Spacer()
                        NavigationLink(destination: RewardRealityCheckActivity()) {
                            Text("Add New")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)

                    ForEach(rewardChecks.prefix(3)) { check in
                        RewardReversalPreview(check: check)
                            .padding(.horizontal)
                    }

                    if rewardChecks.count > 3 {
                        NavigationLink(destination: FullRewardReversalsList(checks: rewardChecks)) {
                            Text("View All (\(rewardChecks.count))")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Understand Your Digital Habits")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Text("Analyze the true costs of your digital habits and find better alternatives")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    NavigationLink(destination: RewardRealityCheckActivity()) {
                        Text("Create Reward Reversal")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    struct FullRewardReversalsList: View {
        let checks: [RewardRealityCheckActivity.RewardCheck]
        
        var body: some View {
            NavigationView {
                List {
                    ForEach(checks) { check in
                        NavigationLink(destination: RewardRealityCheckActivity()) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(check.habit)
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                HStack {
                                    Text("\(check.perceivedRewards.count) rewards")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text("\(check.actualCosts.count) costs")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    Text("\(check.betterAlternatives.count) alternatives")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                
                                Text("Last updated: \(check.lastEdited.formatted())")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .navigationTitle("All Reward Reversals")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: RewardRealityCheckActivity()) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }

    private var featuredLesson: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Featured Lesson")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            NavigationLink(destination: UnderstandingScreenAddictionView()) {
                lessonCard(icon: "bolt.fill", title: "Understanding Screen Addiction", duration: "12 min")
            }
        }
        .padding()
    }

    private var lessonList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Lessons")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            VStack(spacing: 12) {
                NavigationLink(destination: GroundingView(viewModel: blockerViewModel, scheduleViewModel: scheduleViewModel)) {
                    lessonCard(icon: "hands.sparkles.fill", title: "Five-Sense Grounding", duration: "10 min")
                }

                NavigationLink(destination: LoopImpulseAwarenessView()) {
                    lessonCard(icon: "arrow.triangle.2.circlepath", title: "The Loop and Impulse Awareness", duration: "14 min")
                }

                NavigationLink(destination: BreakingTheLoopView()) {
                    lessonCard(icon: "wand.and.stars", title: "Breaking the Loop: Response Rewiring", duration: "15 min")
                }

                NavigationLink(destination: RewardReversalView()) {
                    lessonCard(icon: "arrow.uturn.down", title: "The Reward Reversal", duration: "12 min")
                }

                NavigationLink(destination: CoreValuesView()) {
                    lessonCard(icon: "star.fill", title: "Core Values and Future Self", duration: "20 min")
                }

                NavigationLink(destination: FutureSelfVisionActivity()) {
                    lessonCard(icon: "eye.fill", title: "Future Self Vision Board", duration: "15 min")
                }

                NavigationLink(destination: LoopBreakerArena()) {
                    lessonCard(icon: "gamecontroller.fill", title: "Loop Breaker Arena", duration: "5 min")
                }

                NavigationLink(destination: LoopMappingExercise()) {
                    lessonCard(icon: "arrow.triangle.branch", title: "Map Your Loop", duration: "7 min")
                }

                NavigationLink(destination: RewardRealityCheckActivity()) {
                    lessonCard(icon: "checkmark.seal.fill", title: "Reward Reality Check", duration: "15 min")
                }
            }
            .padding(.horizontal)
        }
    }

    private var journalButton: some View {
        Button(action: {
            showJournalIntro = true
        }) {
            HStack {
                Image(systemName: "book.closed")
                    .foregroundColor(.white)
                Text("Open Journal")
                    .font(.custom("Avenir Next", size: 18).weight(.semibold))
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func lessonCard(icon: String, title: String, duration: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 48, height: 48)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Avenir Next", size: 16).weight(.semibold))
                    .foregroundColor(.white)
                Text(duration)
                    .font(.custom("Avenir Next", size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func loadVisionBoard() {
        if let data = UserDefaults.standard.data(forKey: "savedVisionBoard"),
           let board = try? JSONDecoder().decode(VisionBoard.self, from: data) {
            visionBoard = board
        }
    }

    private func loadRewardChecks() {
        if let data = UserDefaults.standard.data(forKey: "savedRewardChecks"),
           let decoded = try? JSONDecoder().decode([RewardRealityCheckActivity.RewardCheck].self, from: data) {
            rewardChecks = decoded.sorted { $0.lastEdited > $1.lastEdited }
        }
    }
}

