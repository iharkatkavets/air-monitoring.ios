//
//  AllSensorsListView.swift
//  Air
//
//  Created by Ihar Katkavets on 12/12/2025.
//

import SwiftUI

struct SensorHistoryListView: View {
    let viewModel: SensorHistoryListViewModel

    private struct MeasurementsRoute: Hashable {
        let sensorID: String
    }
    
    var body: some View {
        List(viewModel.displaySensors) { sensor in
            NavigationLink(value: MeasurementsRoute(sensorID: sensor.sensorID)) {
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
        .navigationTitle("Hsitory")
        .toolbarTitleDisplayMode(.inline)
        .navigationDestination(for: MeasurementsRoute.self) { route in
            MeasurementsScreen(
                title: route.sensorID,
                viewModel: MeasurementsScreenViewModel(route.sensorID))
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear(perform: viewModel.viewDidTriggerOnAppear)
        .overlay(content: {
            if viewModel.isLoading {
                ProgressView()
            }
        })
        .overlay {
            if !viewModel.isLoading, let error = viewModel.errorMessage {
                ContentUnavailableView(
                    "\(error)",
                    systemImage: "icloud.slash.fill",
                    description: nil)
            }
            else if !viewModel.isLoading, viewModel.displaySensors.isEmpty {
                ContentUnavailableView(
                    "No available sensors",
                    systemImage: "exclamationmark.warninglight.fill",
                    description: nil)
            }
        }
    }
}

#Preview {
    SensorHistoryListView(viewModel: SensorHistoryListViewModel())
}
