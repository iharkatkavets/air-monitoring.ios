//
//  AllSensorsListView.swift
//  Air
//
//  Created by Ihar Katkavets on 12/12/2025.
//

import SwiftUI

struct AllSensorsListView: View {
    let viewModel: AllSensorsListViewModel
    
    var body: some View {
        NavigationStack {
            List(viewModel.displaySensors) { sensor in
                NavigationLink {
                    MeasurementsScreen(
                        title: sensor.sensorID,
                        viewModel: MeasurementsScreenViewModel(sensor.sensorID))
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
}

#Preview {
    AllSensorsListView(viewModel: AllSensorsListViewModel())
}
