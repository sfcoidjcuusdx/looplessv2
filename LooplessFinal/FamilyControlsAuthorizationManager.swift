//
//  FamilyControlsAuthorizationManager.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  FamilyControlsAuthorizationManager.swift
//  loopless
//
//  Created by rafiq kutty on 6/28/25.
//


import FamilyControls
import DeviceActivity
import ManagedSettings

class FamilyControlsAuthorizationManager {
    static let shared = FamilyControlsAuthorizationManager()

    func requestAuthorization() {
        AuthorizationCenter.shared.requestAuthorization { result in
            switch result {
            case .success:
                print("✅ Screen Time authorization granted.")
            case .failure(let error):
                print("❌ Authorization failed: \(error)")
            }
        }
    }
}