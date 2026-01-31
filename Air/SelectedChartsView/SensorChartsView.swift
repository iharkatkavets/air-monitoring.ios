//
//  SensorChartsView.swift
//  Air
//
//  Created by Ihar Katkavets on 25/01/2026.
//

import SwiftUI

struct SensorChartsView: View {
    @State var viewModel: SensorChartsViewModel
    var isAlertPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    var body: some View {
        list
        .task { await viewModel.viewDidTriggerOnAppear() }
        .navigationTitle(viewModel.sensorID)
        .toolbarTitleDisplayMode(.inline)
        .alert(
            "Data Retreiving Error",
            isPresented: isAlertPresented,
            actions: {
                Button("OK", role: .close) {
                    viewModel.errorMessage = nil
                }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
    
    private var list: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.chartsViewModels.keys.sorted(), id: \.self) {
                    MeasurementChart(viewModel: viewModel.chartsViewModels[$0]!)
                        .frame(height: 300)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func listHeader(_ sensorID: String) -> some View {
        HStack {
            Text(sensorID)
                .foregroundStyle(.white)
        }
    }
    
    @ViewBuilder
    private func errorViewIfNeeded() -> some View {
        if let errorMessage = viewModel.errorMessage {
            Button(action: viewModel.userDidPressTryAgain) {
                VStack(alignment: .center, spacing: 0) {
                    Text("Error")
                    Text(errorMessage)
                }
            }
        }
    }
}

#Preview {
    SensorChartsView(viewModel: SensorChartsViewModel("", []))
}
