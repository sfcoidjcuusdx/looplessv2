//
//  LessonListSectionView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct LessonListSectionView: View {
    var blockerViewModel: BlockerViewModel
    var scheduleViewModel: ScheduleViewModel

    var body: some View {
        LessonListSection(
            blockerViewModel: blockerViewModel,
            scheduleViewModel: scheduleViewModel
        )
    }
}
