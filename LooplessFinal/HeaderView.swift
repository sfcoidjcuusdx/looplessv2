//
//  HeaderView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Spacer()

            Image(uiImage: UIImage(named: "avatar-1") ?? UIImage())
                .resizable()
                .frame(width: 28, height: 28)
                .clipShape(Circle())
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.black)
        .overlay(Divider().background(Color.white.opacity(0.2)), alignment: .bottom)
    }
}
