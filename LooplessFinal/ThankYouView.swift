//
//  ThankYouView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/15/25.
//


import SwiftUI

struct ThankYouView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .foregroundColor(.pink)

            Text("Thank You")
                .font(.title)
                .bold()

            Text("Your reflection will help Loopless personalize your recovery.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding()

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}
