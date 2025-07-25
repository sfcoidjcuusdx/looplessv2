//
//  VisionBoardSection.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//


import SwiftUI

struct VisionBoardSection: View {
    @Binding var visionBoard: VisionBoard?
    @Binding var showFullScreen: Bool

    var body: some View {
        Group {
            if let board = visionBoard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Your Digital Vision", systemImage: "eye")
                            .font(.headline)
                        Spacer()
                        Button("Expand") {
                            showFullScreen = true
                        }
                        .font(.caption)
                    }

                    VisionBoardPreview(
                        values: board.values,
                        description: board.description,
                        currentHabits: board.currentHabits,
                        idealHabits: board.idealHabits
                    )
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Design Your Digital Future", systemImage: "sparkles")
                        .font(.headline)
                    Text("Create a vision board to guide your relationship with technology")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    NavigationLink("Create Vision Board", destination: FutureSelfVisionActivity())
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct VisionBoardSheet: View {
    let board: VisionBoard?

    var body: some View {
        if let board = board {
            VisionBoardView(
                values: board.values,
                description: board.description,
                currentHabits: board.currentHabits,
                idealHabits: board.idealHabits
            )
        } else {
            Text("No Vision Board Available")
        }
    }
}

struct VisionBoardPreview: View {
    let values: [String]
    let description: String
    let currentHabits: [String]
    let idealHabits: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(values.prefix(5), id: \.self) { value in
                        Text(value)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(20)
                    }
                }
            }

            Text(description.prefix(140) + (description.count > 140 ? "..." : ""))
                .font(.footnote)
                .foregroundColor(.secondary)

            if let current = currentHabits.first, let ideal = idealHabits.first {
                HStack {
                    Text(current).strikethrough().foregroundColor(.secondary)
                    Image(systemName: "arrow.right")
                    Text(ideal).bold()
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
