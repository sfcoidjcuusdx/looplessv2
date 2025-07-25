// AppTimeLimit.swift
import Foundation
import ManagedSettings

struct AppTimeLimit: Identifiable, Codable, Hashable {
    let id: UUID
    let tokenData: Data
    var dailyLimitMinutes: Int
    var dateSet: Date? 


    init(tokenData: Data, dailyLimitMinutes: Int, dateSet: Date? = Date()) {
            self.id = UUID()
            self.tokenData = tokenData
            self.dailyLimitMinutes = dailyLimitMinutes
            self.dateSet = dateSet
        }
    
    var token: ApplicationToken? {
        try? PropertyListDecoder().decode(ApplicationToken.self, from: tokenData)
    }
}

