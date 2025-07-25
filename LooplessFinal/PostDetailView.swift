import SwiftUI

struct PostDetailView: View {
    @Binding var post: CommunityPost
    @EnvironmentObject var userProfile: UserProfileManager
    @State private var replyText = ""

    var body: some View {
        VStack(spacing: 16) {
            // Post Header
            PostCardView(post: post)
                .padding(.horizontal)

            // Replies Title
            Text("Replies")
                .font(.headline)
                .padding(.horizontal)

            // Comments Scroll
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(post.comments) { comment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("u/\(comment.username)")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text(comment.content)
                                .font(.body)
                                .foregroundColor(.primary)

                            Text(comment.timestamp, style: .relative)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
            }

            // Reply Field
            HStack(spacing: 10) {
                TextField("Write a reply...", text: $replyText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

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
                        .padding(8)
                        .background(replyText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.accentColor)
                        .clipShape(Circle())
                }
                .disabled(replyText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
    }
}

