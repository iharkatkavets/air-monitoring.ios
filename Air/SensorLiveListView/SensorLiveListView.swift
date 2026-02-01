//
//  SensorLiveListView.swift
//  Air
//
//  Created by Ihar Katkavets on 25/01/2026.
//

import SwiftUI

struct SensorLiveListView: View {
    @State var viewModel: SensorLiveListViewModel
    
    var body: some View {
        List(viewModel.displaySensors) { sensor in
            NavigationLink {
                SensorChartsView(
                    viewModel: viewModel.makeSensorChartsViewModel(sensor.sensorID))
            } label: {
                SensorRow(item: sensor, measurements: sensor.measurements)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listStyle(.insetGrouped)
        .navigationTitle("Sensors")
        .toolbarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refresh()
        }
        .task{ await viewModel.viewDidTriggerOnAppear() }
        .overlay(content: {
            if viewModel.isLoading {
                ProgressView()
            }
        })
        .overlay {
            if let error = viewModel.errorMessage {
                ContentUnavailableView(
                    "\(error)",
                    systemImage: "icloud.slash.fill",
                    description: nil)
            }
            else if case .loaded(let displaySensors) = viewModel.state, displaySensors.isEmpty {
                ContentUnavailableView(
                    "No available sensors",
                    systemImage: "exclamationmark.warninglight.fill",
                    description: nil)
            }
        }
    }
}

#Preview {
    SensorLiveListView(viewModel: SensorLiveListViewModel())
}
