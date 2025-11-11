//
//  AppSettings.swift
//  Air
//
//  Created by Ihar Katkavets on 29/10/2025.
//

import Foundation

struct AppSettings {
    @UserDefaultsValue("serverDomain")
    static var serverDomain: ServerDomain = ""
    
    @UserDefaultsValue(ServerSettingKey.maxAge)
    static var maxAge: DurationSeconds = 60*60*24*7
    
    @UserDefaultsValue(ServerSettingKey.storeInterval)
    static var storeInterval: DurationSeconds = 60
}
