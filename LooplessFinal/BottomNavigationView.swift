//
//  BottomNavigationView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import SwiftUI

struct BottomNavigationView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            navButton(icon: "house.fill", tab: .home)
            navButton(icon: "brain.head.profile", tab: .therapy)
            navButton(icon: "calendar", tab: .blocking)
            navButton(icon: "target", tab: .rewards)
            navButton(icon: "person.3.fill", tab: .community)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(
            Color.black
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 0.5),
            alignment: .top
        )
    }

    private func navButton(icon: String, tab: AppTab) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(selectedTab == tab ? .cyan : .gray)

        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTab = tab
        }
    }
}

