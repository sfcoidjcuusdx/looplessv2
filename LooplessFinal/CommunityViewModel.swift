//
//  CommunityViewModel.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  CommunityViewModel.swift
//  loopless
//
//  Created by rafiq kutty on 6/29/25.
//


import Foundation

class CommunityViewModel: ObservableObject {
    @Published var posts: [CommunityPost] = []

    init() {
        fetchPosts()
    }

    func fetchPosts() {
        CommunityService.fetchPosts { posts in
            self.posts = posts
        }
    }

    func addPost(_ post: CommunityPost) {
        posts.insert(post, at: 0)
    }
}
