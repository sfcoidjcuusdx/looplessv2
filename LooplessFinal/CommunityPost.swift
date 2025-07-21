//
//  CommunityPost.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import Foundation

struct CommunityPost: Identifiable, Codable {
    var id: String { _id }
    let _id: String
    var title: String
    var content: String
    var username: String
    var timestamp: Date
    var comments: [Comment]

    struct Comment: Identifiable, Codable {
        var id: String { _id }
        let _id: String
        var username: String
        var content: String
        var timestamp: Date
    }
}

