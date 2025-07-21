//
//  ReflectionView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/15/25.
//


import SwiftUI

struct ReflectionView: View {
    @State private var text = ""
    @State private var showThankYou = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Time to Reflect")
                .font(.title)
                .bold()
                .padding()

            Text("What made you want to open that app?")
                .multilineTextAlignment(.center)

            TextEditor(text: $text)
                .frame(height: 150)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            Button("Submit Reflection") {
                showThankYou = true
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showThankYou) {
            ThankYouView()
        }
    }
}
