//
//  PickupCountView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/21/25.
//


import SwiftUI

struct PickupCountView: View {
    @AppStorage("pickupCount", store: UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData"))
    private var pickupCount: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("📲 Daily Pickups")
                .font(.title2)
                .bold()

            Text("\(pickupCount)")
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(.blue)

            Text("Pickups so far today")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
