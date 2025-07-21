//
//  AppSelectionView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  AppSelectionView.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//


import SwiftUI
import FamilyControls
import ManagedSettings

struct AppSelectionView: View {
    @State private var selection = FamilyActivitySelection()

    var body: some View {
        FamilyActivityPicker(selection: $selection)
            .onChange(of: selection) { newValue in
                try? ManagedSettingsStore().shield.applications = newValue.applicationTokens
                print("Selected apps: \(newValue)")
            }
    }
}