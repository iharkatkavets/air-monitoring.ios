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
}
