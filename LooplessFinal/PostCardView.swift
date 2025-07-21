//
//  PostCardView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import SwiftUI

struct PostCardView: View {
    var post: CommunityPost

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 📝 Title
            Text(post.title)
                .font(.custom("AvenirNext-Bold", size: 20))
                .foregroundColor(.white)

            // 📄 Content
            Text(post.content)
                .font(.custom("AvenirNext-Regular", size: 16))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            // 🧑‍💻 Username + 🕒 Timestamp
            HStack {
                Text("u/\(post.username)")
                    .font(.custom("AvenirNext-Medium", size: 12))
                    .foregroundColor(.purple.opacity(0.8))

                Spacer()

                Text(post.timestamp, style: .relative)
                    .font(.custom("AvenirNext-Regular", size: 12))
                    .foregroundColor(.gray.opacity(0.8))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
    }
}

