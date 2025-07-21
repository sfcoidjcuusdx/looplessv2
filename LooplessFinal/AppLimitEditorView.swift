//
//  AppLimitEditorView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  AppLimitEditorView.swift
//  loopless
//
//  Created by rafiq kutty on 6/18/25.
//

import SwiftUI

struct AppLimitEditorView: View {
    let app: BlockedApp
    let currentLimit: Int
    let onSave: (Int) -> Void
    @State private var limit: Int

    init(app: BlockedApp, currentLimit: Int, onSave: @escaping (Int) -> Void) {
        self.app = app
        self.currentLimit = currentLimit
        self.onSave = onSave
        self._limit = State(initialValue: currentLimit)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Time Limit for \(app.name)")
                .font(.headline)

            Stepper("Limit: \(limit) minutes", value: $limit, in: 5...240, step: 5)

            Button("Save") {
                onSave(limit)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
