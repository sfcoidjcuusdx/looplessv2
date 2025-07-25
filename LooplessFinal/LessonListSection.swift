//
//  LessonListSection.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct LessonListSection: View {
    let blockerViewModel: BlockerViewModel
    let scheduleViewModel: ScheduleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("All Lessons", systemImage: "list.bullet.rectangle")
                .font(.headline)

            Group {
                NavigationLink(destination: GroundingView(viewModel: blockerViewModel, scheduleViewModel: scheduleViewModel)) {
                    LessonCard(icon: "hands.sparkles.fill", title: "Five-Sense Grounding", duration: "10 min")
                }
                NavigationLink(destination: LoopImpulseAwarenessView()) {
                    LessonCard(icon: "arrow.triangle.2.circlepath", title: "Loop and Impulse Awareness", duration: "14 min")
                }
                NavigationLink(destination: BreakingTheLoopView()) {
                    LessonCard(icon: "wand.and.stars", title: "Breaking the Loop", duration: "15 min")
                }
                NavigationLink(destination: RewardReversalView()) {
                    LessonCard(icon: "arrow.uturn.down", title: "Reward Reversal", duration: "12 min")
                }
                NavigationLink(destination: CoreValuesView()) {
                    LessonCard(icon: "star.fill", title: "Core Values", duration: "20 min")
                }
                NavigationLink(destination: FutureSelfVisionActivity()) {
                    LessonCard(icon: "eye.fill", title: "Vision Board", duration: "15 min")
                }
                NavigationLink(destination: LoopBreakerArena()) {
                    LessonCard(icon: "gamecontroller.fill", title: "Loop Breaker Arena", duration: "5 min")
                }
                NavigationLink(destination: LoopMappingExercise()) {
                    LessonCard(icon: "arrow.triangle.branch", title: "Map Your Loop", duration: "7 min")
                }
                NavigationLink(destination: RewardRealityCheckActivity()) {
                    LessonCard(icon: "checkmark.seal.fill", title: "Reward Reality Check", duration: "15 min")
                }
            }
        }
    }
}

struct LessonCard: View {
    let icon: String
    let title: String
    let duration: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 44, height: 44)
                .background(Color(.systemGray5))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body)
                Text(duration).font(.caption).foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}
