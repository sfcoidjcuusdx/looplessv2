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
        VStack(alignment: .leading, spacing: 16) {
            Text("Selected Apps")
                .font(.title2)
                .bold()

            if dataModel.selection.applicationTokens.isEmpty {
                Text("No apps selected.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(dataModel.selection.applicationTokens), id: \.self) { token in
                            Label(token)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

