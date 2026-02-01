//
//  RootView.swift
//  Air
//
//  Created by Ihar Katkavets on 24/12/2025.
//

import SwiftUI

struct RootView: View {
    @State private var sensorsPath = NavigationPath()
    @State private var chartsPath  = NavigationPath()
    @State private var historyPath = NavigationPath()
    @State private var settingsPath = NavigationPath()
    @State var viewModel: RootViewModel
    
    var body: some View {
        TabView {
            Tab("Sensors", systemImage: "sensor.fill") {
                NavigationStack(path: $sensorsPath) {
                    SensorLiveListView(viewModel: viewModel.sensorLiveListViewModel)
                }
            }
            Tab("Charts", systemImage: "chart.xyaxis.line") {
                NavigationStack(path: $chartsPath) {
                    SelectedChartsView(viewModel: viewModel.chartsScreenViewModel)
                }
            }
            Tab("History", systemImage: "clock.fill") {
                NavigationStack(path: $historyPath) {
                    SensorHistoryListView(viewModel: viewModel.sensorHistoryListViewModel)
                }
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                NavigationStack(path: $settingsPath) {
                    SettingsScreen(viewModel: viewModel.settingsViewModel)
                }
            }
        }
        .onAppear(perform: viewModel.viewDidTriggerOnAppear)
        .onReceive(viewModel.popToRoot) { _ in
            popToRoot()
        }
        .preferredColorScheme(.dark)
        .background(Color.black)
    }
    
    private func popToRoot() {
        sensorsPath = NavigationPath()
        chartsPath  = NavigationPath()
        historyPath = NavigationPath()
    }
}
