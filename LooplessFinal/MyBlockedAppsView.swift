//
//  MyBlockedAppsView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import SwiftUI
import FamilyControls

struct MyBlockedAppsView: View {
    @EnvironmentObject var dataModel: LooplessDataModel

    var body: some View {
        VStack(spacing: 16) {
            Text("📵 My Blocked Apps")
                .font(.largeTitle.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            List {
                if dataModel.selection.applicationTokens.isEmpty {
                    Text("No apps selected yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(Array(arrayLiteral: dataModel.selection.applicationTokens), id: \.self) { token in
                        Text(token.debugDescription)
                            .foregroundColor(.white)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.black, Color.indigo.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Blocked Apps")
        .navigationBarTitleDisplayMode(.inline)
    }
}
