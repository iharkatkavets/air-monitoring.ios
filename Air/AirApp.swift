//
//  AirApp.swift
//  Air
//
//  Created by Ihar Katkavets on 18/10/2025.
//

import SwiftUI

@main
struct AirApp: App {
    @StateObject private var settingsViewModel = SettingsScreenViewModel()
    @StateObject private var chartsScreenViewModel = ChartsScreenViewModel()
    private let allSensorsListViewModel = AllSensorsListViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Sensors", systemImage: "sensor.fill") {
                    NavigationStack {
                        AllSensorsListView(viewModel: allSensorsListViewModel)
                    }
                }
                Tab("Charts", systemImage: "chart.xyaxis.line") {
                    NavigationStack {
                        ChartsScreen(viewModel: chartsScreenViewModel)
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
