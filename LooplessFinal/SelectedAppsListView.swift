//
//  SelectedAppsListView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//

import SwiftUI
import FamilyControls

struct SelectedAppsListView: View {
    @EnvironmentObject var dataModel: LooplessDataModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📱 Selected Apps")
                .font(.title2.bold())
                .foregroundColor(.white)

            if dataModel.selection.applicationTokens.isEmpty {
                Text("No apps selected.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Convert Set to Array for ForEach
                        ForEach(Array(dataModel.selection.applicationTokens), id: \.self) { token in
                            Label(token)
                                .padding(8)
                                .background(Color.blue.opacity(0.3))
                                .cornerRadius(8)
                                .scaleEffect(1.2) // scale text size a bit
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.black, .gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(12)
        )
    }
}

