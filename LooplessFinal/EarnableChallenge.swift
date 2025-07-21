//
//  EarnableChallenge.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/17/25.
//


import Foundation

struct EarnableChallenge: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let points: Int
    let isCompleted: Bool
}
