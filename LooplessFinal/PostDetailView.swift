//
//  PostDetailView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import SwiftUI

struct PostDetailView: View {
    @Binding var post: CommunityPost
    @EnvironmentObject var userProfile: UserProfileManager
    @State private var replyText = ""

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                // Post Header
                PostCardView(post: post)
                    .padding(.horizontal)

                // Replies Title
                Text("Replies")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(.white)
                    .padding(.horizontal)

                // Comments Scroll
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(post.comments) { comment in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("u/\(comment.username)")
                                    .font(.custom("AvenirNext-Medium", size: 14))
                                    .foregroundColor(.purple)

                                Text(comment.content)
                                    .font(.custom("AvenirNext-Regular", size: 16))
                                    .foregroundColor(.white)

                                Text(comment.timestamp, style: .relative)
                                    .font(.custom("AvenirNext-Regular", size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .background(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                // Reply Field
                HStack(spacing: 12) {
                    TextField("Write a reply...", text: $replyText)
                        .font(.custom("AvenirNext-Regular", size: 16))
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .foregroundColor(.white)
                        .cornerRadius(12)

                    Button(action: {
                        let newComment = CommunityPost.Comment(
                            _id: UUID().uuidString,
                            username: userProfile.username,
                            content: replyText,
                            timestamp: Date()
                        )

                        
                        post.comments.append(newComment)
                        replyText = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(replyText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : Color.purple)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .disabled(replyText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

