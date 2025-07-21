//
//  ForumView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import SwiftUI

struct ForumView: View {
    @EnvironmentObject var userProfile: UserProfileManager
    @EnvironmentObject var viewModel: CommunityViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewPost = false

    var body: some View {
        ZStack {
            // 🔮 Dark Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(.darkGray)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    // ⬅️ Custom Back Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.leading)

                    Spacer()

                    Text("Community Forum")
                        .font(.custom("AvenirNext-Bold", size: 24))
                        .foregroundColor(.white)

                    Spacer()

                    // ➕ Create New Post
                    Button(action: { showingNewPost = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.purple)
                            .shadow(radius: 5)
                    }
                    .padding(.trailing)
                }
                .padding(.top, 40)

                // 📄 Posts List
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach($viewModel.posts, id: \.id) { $post in
                            NavigationLink(destination: PostDetailView(post: $post).environmentObject(userProfile)) {
                                PostCardView(post: post)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingNewPost) {
            NewPostView(viewModel: viewModel)
                .environmentObject(userProfile)
        }
        .navigationBarHidden(true)
    }
}

