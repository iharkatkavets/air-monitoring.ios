//
//  RootView.swift
//  Air
//
//  Created by Ihar Katkavets on 24/12/2025.
//

import SwiftUI

struct RootView: View {
    @State var viewModel: RootViewModel
    
    var body: some View {
        TabView {
            Tab("Sensors", systemImage: "sensor.fill") {
                NavigationStack {
                    AllSensorsListView(viewModel: viewModel.allSensorsListViewModel)
                }
            }
            Tab("Charts", systemImage: "chart.xyaxis.line") {
                NavigationStack {
                    ChartsScreen(viewModel: viewModel.chartsScreenViewModel)
                }
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                NavigationStack {
                    SettingsScreen(viewModel: viewModel.settingsViewModel)
                }
            }
        }
        .preferredColorScheme(.dark)
        .background(Color.black)
    }
}
