import SwiftUI

struct NewPostView: View {
    @EnvironmentObject var userProfile: UserProfileManager
    @ObservedObject var viewModel: CommunityViewModel
    @State private var title = ""
    @State private var content = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter post title", text: $title)
                }

                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
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
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || content.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

