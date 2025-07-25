import SwiftUI

struct ForumView: View {
    @EnvironmentObject var userProfile: UserProfileManager
    @EnvironmentObject var viewModel: CommunityViewModel
    @State private var showingNewPost = false

    var body: some View {
        List {
            ForEach($viewModel.posts, id: \.id) { $post in
                NavigationLink(destination: PostDetailView(post: $post).environmentObject(userProfile)) {
                    PostCardView(post: post)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Community Forum")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingNewPost = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewPost) {
            NewPostView(viewModel: viewModel)
                .environmentObject(userProfile)
        }
    }
}

