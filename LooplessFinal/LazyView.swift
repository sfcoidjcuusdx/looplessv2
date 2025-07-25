//
//  LazyView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/24/25.
//

import SwiftUI
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: some View {
        build()
    }
}
