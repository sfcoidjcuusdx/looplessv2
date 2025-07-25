//
//  TherapyMainScrollView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct TherapyMainScrollView: View {
    @ObservedObject var blockerViewModel: BlockerViewModel
    @ObservedObject var scheduleViewModel: ScheduleViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                VisionBoardSectionView()
                LoopMappingSectionView()
                RewardReversalSectionView()
                FeaturedLessonSectionView()
                LessonListSectionView(
                    blockerViewModel: blockerViewModel,
                    scheduleViewModel: scheduleViewModel
                )
                JournalButtonsSectionView()
            }
            .padding(.vertical)
            .padding(.horizontal, 16)
        }
    }
}
