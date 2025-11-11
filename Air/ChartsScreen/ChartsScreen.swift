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
                MeasurementPMChart(
                    xAxisTitle: "Particles Count",
                    yAxisTitle: "Time",
                    minValue: viewModel.particlesCountMinValue,
                    maxValue: viewModel.particlesCountMaxValue,
                    values: viewModel.particlesCount)
                .containerRelativeFrame(.vertical, alignment: .top, halfHeight)
                
                MeasurementPMChart(
                    xAxisTitle: "Mass Density",
                    yAxisTitle: "Time",
                    minValue: viewModel.massDensityMinValue,
                    maxValue: viewModel.massDensityMaxValue,
                    values: viewModel.massDensity)
                .containerRelativeFrame(.vertical, alignment: .top, halfHeight)
            }
            .padding(.horizontal)
        }
        .onAppear { viewModel.viewDidTriggerOnAppear() }
        .navigationTitle("Live Charts")
        .toolbarTitleDisplayMode(.inline)
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
