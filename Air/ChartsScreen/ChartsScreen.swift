//
//  ChartsScreen.swift
//  Air
//
//  Created by Ihar Katkavets on 31/10/2025.
//

import SwiftUI

struct ChartsScreen: View {
    @ObservedObject var viewModel: ChartsScreenViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                MeasurementChart(viewModel: viewModel.particlesCountChartViewModel)
                    .containerRelativeFrame(.vertical, alignment: .top, halfHeight)
                
                MeasurementChart(viewModel: viewModel.massDensityChartViewModel)
                    .containerRelativeFrame(.vertical, alignment: .top, halfHeight)
            }
            .padding(.horizontal)
        }
        .onAppear { viewModel.viewDidTriggerOnAppear() }
        .navigationTitle("Live Charts")
        .toolbarTitleDisplayMode(.inline)
        .alert("Data Retreiving Error",
               isPresented: .constant(viewModel.errorMessage != nil),
               actions: {
            Button("OK", role: .close) {
                viewModel.errorMessage = nil
            }
            Button("Retry", role: .confirm) {
                viewModel.fetchMeasurements()
            }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
    
    private func halfHeight(_ length: CGFloat, _ axis: Axis) -> CGFloat {
        (length-32) * 0.5
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
    ChartsScreen(viewModel: ChartsScreenViewModel())
}
