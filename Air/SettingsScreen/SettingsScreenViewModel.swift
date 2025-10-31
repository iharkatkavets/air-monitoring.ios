//
//  SettingsScreenViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 29/10/2025.
//

import Foundation
import Combine


@MainActor
final class SettingsScreenViewModel: ObservableObject {
    @Published var serverDomain: String = AppSettings.serverDomain {
        didSet {
            AppSettings.serverDomain = serverDomain
        }
    }
    
    init() {
        
    }
}
