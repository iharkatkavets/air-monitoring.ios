//
//  ChartsGroupView.swift
//  Air
//
//  Created by Ihar Katkavets on 08/12/2025.
//

import SwiftUI

struct ChartsGroupView: View {
    let spacing: CGFloat
    let height: CGFloat
    @ObservedObject var viewModel: ChartsGroupViewModel
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(viewModel.chartsViewModels.keys.sorted(), id: \.self) {
                MeasurementChart(viewModel: viewModel.chartsViewModels[$0]!)
                    .frame(height: height)
            }
        }
        .task {
            viewModel.viewDidTriggerOnAppear()
        }
        .onDisappear(perform: viewModel.viewDidTriggerOnDisappear)
    }
}

#Preview {
//    ChartsGroupView()
}
