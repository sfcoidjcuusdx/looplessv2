import SwiftUI
import Speech

struct TherapyScreenView: View {
    @Binding var selectedTab: AppTab
    @Binding var showReflectionPopup: Bool

    @EnvironmentObject var viewModel: BlockerViewModel
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel

    @State private var hasLoadedData = false
    @State private var showJournalIntro = false
    @State private var navigateToJournal = false
    @State private var visionBoard: VisionBoard? = nil
    @State private var showVisionBoardFullScreen = false
    @State private var rewardChecks: [RewardRealityCheckActivity.RewardCheck] = []
    @State private var showVoiceJournal = false
    @State private var speechPermissionDenied = false

    @AppStorage("savedTrigger") private var savedTrigger: String = ""
    @AppStorage("savedBehavior") private var savedBehavior: String = ""
    @AppStorage("savedOutcome") private var savedOutcome: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    VisionBoardSection(
                        visionBoard: $visionBoard,
                        showFullScreen: $showVisionBoardFullScreen
                    )

                    LoopMappingSection(
                        savedTrigger: savedTrigger,
                        savedBehavior: savedBehavior,
                        savedOutcome: savedOutcome
                    )

                    RewardReversalSection(
                        rewardChecks: $rewardChecks
                    )

                    FeaturedLessonSectionView()

                    LessonListSection(
                        blockerViewModel: viewModel,
                        scheduleViewModel: scheduleViewModel
                    )

                    JournalButtonsSection(
                        showJournalIntro: $showJournalIntro,
                        showVoiceJournal: $showVoiceJournal,
                        speechPermissionDenied: $speechPermissionDenied
                    )
                }
                .padding(.vertical)
                .padding(.horizontal, 16)
            }
            .navigationTitle("Therapy Lessons")
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $navigateToJournal) {
                JournalView()
            }
            .sheet(isPresented: $showVisionBoardFullScreen) {
                VisionBoardSheet(board: visionBoard)
            }
            .sheet(isPresented: $showJournalIntro) {
                JournalIntroPopup(navigateToJournal: $navigateToJournal)
            }
            .sheet(isPresented: $showVoiceJournal) {
                VoiceJournalView()
            }
        }
        .fullScreenCover(isPresented: $showReflectionPopup) {
            ReflectionPopupView {
                showReflectionPopup = false
            }
        }
        .task {
            if !hasLoadedData {
                hasLoadedData = true
                await loadDataIfNeeded()
            }
        }
    }

    @MainActor
    private func loadDataIfNeeded() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await loadVisionBoard() }
            group.addTask { await loadRewardChecks() }
        }
    }

    @MainActor
    private func loadVisionBoard() async {
        if let data = UserDefaults.standard.data(forKey: "savedVisionBoard"),
           let board = try? JSONDecoder().decode(VisionBoard.self, from: data) {
            visionBoard = board
        }
    }

    @MainActor
    private func loadRewardChecks() async {
        if let data = UserDefaults.standard.data(forKey: "savedRewardChecks"),
           let decoded = try? JSONDecoder().decode([RewardRealityCheckActivity.RewardCheck].self, from: data) {
            rewardChecks = decoded.sorted { $0.lastEdited > $1.lastEdited }
        }
    }
}

