//
//  UserProfileManager.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  UserProfileManager.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//


import Foundation
import SwiftUI

class UserProfileManager: ObservableObject {
    @AppStorage("username") var username: String = ""

    var hasUsername: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
