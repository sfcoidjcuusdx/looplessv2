//
//  TherapyState.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

final class TherapyState: ObservableObject {
    @Published var showJournalIntro = false
    @Published var navigateToJournal = false
    @Published var visionBoard: VisionBoard? = nil
    @Published var showVisionBoardFullScreen = false
    @Published var rewardChecks: [RewardRealityCheckActivity.RewardCheck] = []
    @Published var showVoiceJournal = false
    @Published var speechPermissionDenied = false

    @AppStorage("savedTrigger") var savedTrigger: String = ""
    @AppStorage("savedBehavior") var savedBehavior: String = ""
    @AppStorage("savedOutcome") var savedOutcome: String = ""

    @MainActor
    func loadData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadVisionBoard() }
            group.addTask { await self.loadRewardChecks() }
        }
    }

    @MainActor
    private func loadVisionBoard() async {
        if let data = UserDefaults.standard.data(forKey: "savedVisionBoard"),
           let board = try? JSONDecoder().decode(VisionBoard.self, from: data) {
            self.visionBoard = board
        }
    }

    @MainActor
    private func loadRewardChecks() async {
        if let data = UserDefaults.standard.data(forKey: "savedRewardChecks"),
           let decoded = try? JSONDecoder().decode([RewardRealityCheckActivity.RewardCheck].self, from: data) {
            self.rewardChecks = decoded.sorted { $0.lastEdited > $1.lastEdited }
        }
    }
}
