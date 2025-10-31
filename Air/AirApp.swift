//
//  AirApp.swift
//  Air
//
//  Created by Ihar Katkavets on 18/10/2025.
//

import SwiftUI

@main
struct AirApp: App {
    @StateObject private var measurementsViewModel = MeasurementsScreenViewModel()
    @StateObject private var settingsViewModel = SettingsScreenViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Measurements", systemImage: "house.fill") {
                    NavigationStack {
                        MeasurementsScreen(viewModel: measurementsViewModel)
                    }
                }
                Tab("Settings", systemImage: "gearshape.fill") {
                    NavigationStack {
                        SettingsScreen(viewModel: settingsViewModel)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .background(Color.black)
        }
    }
}
