//
//  VisionBoardSectionView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct VisionBoardSectionView: View {
    @EnvironmentObject private var state: TherapyState

    var body: some View {
        VisionBoardSection(
            visionBoard: $state.visionBoard,
            showFullScreen: $state.showVisionBoardFullScreen
        )
    }
}
