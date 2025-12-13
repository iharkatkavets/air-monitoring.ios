//
//  AppSettings.swift
//  Air
//
//  Created by Ihar Katkavets on 29/10/2025.
//

import Foundation
import Collections

enum AppSettings {
    struct SensorConfig: Identifiable, Codable {
        let id: SensorID
        let name: SensorName
        let measurements: [Measurement]
    }
    
    
    @UserDefaultsValue("serverDomain")
    static var serverDomain: ServerDomain = ""
    
    @UserDefaultsValue(ServerSettingKey.maxAge)
    static var maxAge: DurationSeconds = 60*60*24*7
    
    @UserDefaultsValue(ServerSettingKey.storeInterval)
    static var storeInterval: DurationSeconds = 60
    
    @UserDefaultsValue("sensors")
    static var sensors: [SensorConfig] = []
}
