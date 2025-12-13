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
            .padding(.horizontal)
            .task { await viewModel.viewDidTriggerOnAppear() }
            .overlay(content: {
                if viewModel.isLoading {
                    ProgressView()
                }
            })
            .overlay {
                if !viewModel.isLoading, let error = viewModel.error {
                    ContentUnavailableView(
                        "\(error)",
                        systemImage: "doc.richtext.fill",
                        description: Text("Try to search for another title.")
                    )
                }
                else if !viewModel.isLoading, viewModel.displaySensors.isEmpty {
                    ContentUnavailableView(
                        "No available sensors",
                        systemImage: "doc.richtext.fill",
                        description: Text("Check that server has data")
                    )
                }
            }
        }
    }
}

#Preview {
    AllSensorsListView(viewModel: AllSensorsListViewModel())
}
