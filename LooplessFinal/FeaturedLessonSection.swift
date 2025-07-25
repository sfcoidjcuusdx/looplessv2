//
//  FeaturedLessonSection.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct FeaturedLessonSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Label("Featured Lesson", systemImage: "star")
                .font(.subheadline)
                .foregroundColor(.secondary)

            NavigationLink(destination: UnderstandingScreenAddictionView()) {
                LessonCard(icon: "bolt.fill", title: "Understanding Screen Addiction", duration: "12 min")
            }
        }
    }
}
