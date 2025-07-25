import SwiftUI

struct PostCardView: View {
    var post: CommunityPost

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 📝 Title
            Text(post.title)
                .font(.headline)
                .foregroundColor(.primary)

            // 📄 Content
            Text(post.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            // 🧑‍💻 Username + 🕒 Timestamp
            HStack {
                Text("u/\(post.username)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                Text(post.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

