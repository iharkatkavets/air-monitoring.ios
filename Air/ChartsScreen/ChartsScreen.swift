//
//  ChartsScreen.swift
//  Air
//
//  Created by Ihar Katkavets on 31/10/2025.
//

import SwiftUI
import MarkdownUI

struct ChartsScreen: View {
    @ObservedObject var viewModel: ChartsScreenViewModel
    @State var isNumberConentrationInfoPresented: Bool = false
    @State var isMassConcentrationInfoPresented: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                MeasurementChart(viewModel: viewModel.particlesCountChartViewModel,
                                 showInfo: $isNumberConentrationInfoPresented)
                    .containerRelativeFrame(.vertical, alignment: .top, halfHeight)
                
                MeasurementChart(viewModel: viewModel.massDensityChartViewModel,
                                 showInfo: $isMassConcentrationInfoPresented)
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
        .sheet(isPresented: $isNumberConentrationInfoPresented, content: {
            infoView("number-concentration-info.md")
        })
        .sheet(isPresented: $isMassConcentrationInfoPresented, content: {
            infoView("mass-concentration-info.md")
        })
    }
    
    
    private func infoView(_ fileName: String) -> some View {
        ScrollView {
            Markdown(MarkdownContent(try! String(contentsOfFile: Bundle.main.path(forResource: fileName, ofType: nil)!, encoding: .utf8)))
                .padding()
        }
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
