//
//  UsernameSetupView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import SwiftUI

struct UsernameSetupView: View {
    @EnvironmentObject var userProfile: UserProfileManager
    @State private var newUsername = ""

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Choose Your Username")
                    .font(.custom("AvenirNext-Bold", size: 28))
                    .foregroundColor(.white)

                TextField("e.g. looplessFan23", text: $newUsername)
                    .font(.custom("AvenirNext-Regular", size: 16))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .background(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)

                Button(action: {
                    userProfile.username = newUsername.trimmingCharacters(in: .whitespaces)
                }) {
                    Text("Save Username")
                        .font(.custom("AvenirNext-Bold", size: 18))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(newUsername.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.4) : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(newUsername.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

