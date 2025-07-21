//
//  EndSessionButtonView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/10/25.
//


import SwiftUI

struct EndSessionButtonView: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("❌ End Session Early")
                .font(.custom("Avenir Next", size: 16).bold())
                .foregroundColor(.red)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
        }
    }
}
