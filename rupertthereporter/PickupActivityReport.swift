//
//  PickupActivityReport.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/21/25.
//


//
//  PickupActivityReport.swift
//  LooplessFinal
//
//  Created by Rafiq Kutty on 7/22/25.
//

import DeviceActivity
import SwiftUI

// MARK: - Report Contexts

extension DeviceActivityReport.Context {
    /// Context for showing total pickups in a custom view
    static let totalPickups = Self("Total Pickups")
}

// MARK: - Total Pickups Report (Custom View)
struct PickupActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalPickups
    let content: (Int) -> PickupActivityView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Int {
        // Get today's date key
        let dateKey = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        
        // Retrieve from UserDefaults where PickupMonitor stores the count
        let totalPickups = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?
            .integer(forKey: "pickupCount-\(dateKey)") ?? 0
        
        return totalPickups
    }
}
// MARK: - Pickup Activity View

struct PickupActivityView: View {
    let pickupCount: Int
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Device Pickups")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(pickupCount)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(pickupCount == 1 ? "time today" : "times today")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

struct PickupActivityView_Previews: PreviewProvider {
    static var previews: some View {
        PickupActivityView(pickupCount: 42)
            .previewLayout(.sizeThatFits)
    }
}
