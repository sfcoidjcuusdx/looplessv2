//
//  AppTab.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  Tab.swift
//  loopless
//
//  Created by rafiq kutty on 6/18/25.
//


// Tab.swift
import Foundation

enum AppTab: String, CaseIterable {
    case home, therapy, blocking, rewards, community

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .therapy: return "brain.head.profile"
        case .blocking: return "calendar"
        case .rewards: return "target"
        case .community: return "person.3.fill"
        }
    }
}

