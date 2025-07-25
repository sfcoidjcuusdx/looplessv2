//
//  DeviceActivityMonitorExtension.swift
//  LooplessFinal
//

import DeviceActivity
import ManagedSettings
import Foundation

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("group.crew.LooplessFinal.sharedData"))
    let appLimitKey = "SavedAppLimits"
    let blockedTokensKey = "BlockedTokens"

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        // Reset shields for the new interval
        store.shield.applications = nil
        print("🔄 intervalDidStart: Reset shields for \(activity.rawValue)")

        reapplyPersistedBlockedTokens()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.removeObject(forKey: self.blockedTokensKey)
            print("🗑️ Cleared persisted blocked tokens after restoring shields")
        }
    }

    // In DeviceActivityMonitorExtension
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        print("🚨 Threshold reached for event: \(event.rawValue)")
        
        guard let data = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.data(forKey: appLimitKey),
              let limits = try? PropertyListDecoder().decode([AppTimeLimit].self, from: data) else {
            print("⚠️ Failed to load app limits")
            return
        }
        
        for limit in limits {
            if event.rawValue.contains(limit.id.uuidString), let token = limit.token {
                store.shield.applications = [token]
                print("🛡️ App \(token) blocked due to limit")
                persistBlockedToken(token)
                persistLimitHitTimestamp(for: token)
                return
            }
        }
        
        print("⚠️ No matching app found for event: \(event.rawValue)")
    }

    private func persistBlockedToken(_ token: ApplicationToken) {
        guard let encoded = try? PropertyListEncoder().encode(token) else { return }

        var existing: [Data] = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.array(forKey: blockedTokensKey) as? [Data] ?? []
        existing.append(encoded)
        UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.set(existing, forKey: blockedTokensKey)
        print("💾 Persisted blocked token")
    }

    private func reapplyPersistedBlockedTokens() {
        guard let dataArray = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.array(forKey: blockedTokensKey) as? [Data] else {
            print("ℹ️ No persisted tokens to reapply")
            return
        }

        let tokens = dataArray.compactMap { try? PropertyListDecoder().decode(ApplicationToken.self, from: $0) }
        if !tokens.isEmpty {
            store.shield.applications = Set(tokens)
            print("🛡️ Reapplied \(tokens.count) persisted shields after interval reset")
        }
    }
    
    private func persistLimitHitTimestamp(for token: ApplicationToken) {
        let key = "LimitHitTimestamps"

        guard let encodedToken = try? PropertyListEncoder().encode(token) else { return }
        let id = encodedToken.base64EncodedString()

        var existing: [String: Date] = (UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.dictionary(forKey: key) as? [String: Date]) ?? [:]
        existing[id] = Date()

        UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")?.set(existing, forKey: key)
        print("🕒 Saved limit hit time for token \(id.prefix(8))...")
    }


}

