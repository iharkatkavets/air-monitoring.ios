//
//  SensorsListView.swift
//  Air
//
//  Created by Ihar Katkavets on 11/12/2025.
//

import SwiftUI

struct SelectableSensorsListView: View {
    @ObservedObject var viewModel: SelectableSensorsListViewModel
    
    var body: some View {
        NavigationStack {
            List(viewModel.displaySensors, selection: $viewModel.selectedSensors) { sensor in
                SelectableSensorRow(item: sensor, measurements: sensor.measurements)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .overlay(content: {
                if viewModel.isLoading {
                    ProgressView()
                }
            })
            .navigationTitle("Available")
            .toolbarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem {
                    Button(role: .confirm, action: viewModel.userDidPressDone)
                        .disabled(viewModel.selectedSensors.isEmpty)
                }
            })
            .padding(.horizontal)
            .task { await viewModel.viewDidTriggerOnAppear() }
            .environment(\.editMode, .constant(.active))
        }
    }
}

#Preview {
    SelectableSensorsListView(
        viewModel: SelectableSensorsListViewModel(
            onError: { _ in },
            onSelectSensors: { _ in })
    )
}
