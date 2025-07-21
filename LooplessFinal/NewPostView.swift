//
//  NewPostView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import SwiftUI

struct NewPostView: View {
    @EnvironmentObject var userProfile: UserProfileManager
    @ObservedObject var viewModel: CommunityViewModel
    @State private var title = ""
    @State private var content = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // 🌌 Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(.darkGray)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("Create New Post")
                    .font(.custom("AvenirNext-Bold", size: 28))
                    .foregroundColor(.white)
                    .padding(.top, 40)

                // 📝 Title Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.custom("AvenirNext-Medium", size: 16))
                        .foregroundColor(.gray)

                    TextField("Enter post title", text: $title)
                        .font(.custom("AvenirNext-Regular", size: 18))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                                .background(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                }

                // ✍️ Content Editor
                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.custom("AvenirNext-Medium", size: 16))
                        .foregroundColor(.gray)

                    TextEditor(text: $content)
                        .font(.custom("AvenirNext-Regular", size: 16))
                        .frame(minHeight: 180)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                                .background(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                }

                Spacer()

                // 🟣 Post + Cancel Buttons
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.custom("AvenirNext-Medium", size: 16))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        CommunityService.createPost(
                            title: title,
                            content: content,
                            username: userProfile.username
                        ) { newPost in
                            if let post = newPost {
                                viewModel.addPost(post)
                                dismiss()
                            }
                        }

                    }) {
                        Text("Post")
                            .font(.custom("AvenirNext-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                            .shadow(radius: 6)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || content.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity((title.trimmingCharacters(in: .whitespaces).isEmpty || content.trimmingCharacters(in: .whitespaces).isEmpty) ? 0.5 : 1.0)
                }
            }
            .padding(.horizontal)
        }
    }
}

