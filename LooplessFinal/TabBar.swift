//
//  TabBar.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/25/25.
//


import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Spacer()
                Button(action: {
                    selectedTab = tab
                }) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? .cyan : .gray)
                }
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
        .shadow(radius: 3)
    }
}
