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
    static var maxAge: DurationSeconds = -1
    
    @UserDefaultsValue(ServerSettingKey.storeInterval)
    static var storeInterval: DurationSeconds = -1
    
    @UserDefaultsValue("sensors")
    static var sensors: [SensorConfig] = []
}
