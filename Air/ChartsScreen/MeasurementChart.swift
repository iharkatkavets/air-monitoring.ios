//
//  ParticlesCountChart.swift
//  Air
//
//  Created by Ihar Katkavets on 02/11/2025.
//

import SwiftUI
import Charts

struct MeasurementChart: View {
    var viewModel: MeasurementChartViewModel
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            chartHeader
            chart
        }
        .opacity(viewModel.isLoading || viewModel.errorMessage != nil ? 0.2 : 1.0)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .overlay { errorView }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
    
    var chartHeader: some View {
        HStack(spacing: 8) {
            yAxisTitle
            Spacer()
            chartTitle
            Spacer()
            Color.clear.frame(width: 16, height: 16)
        }
    }
    
    var yAxisTitle: some View {
        Text(viewModel.yAxisTitle)
            .font(.footnote.weight(.regular))
            .foregroundStyle(.primary.opacity(0.8))
    }

    var chartTitle: some View {
        Text(viewModel.chartTitle)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary.opacity(0.8))
    }
    
    var chart: some View {
        Chart(viewModel.values) { item in
            LineMark(
                x: .value(viewModel.xAxisTitle, item.date),
                y: .value(viewModel.yAxisTitle, item.value)
            )
            .foregroundStyle(by: .value("Param", item.param))
            .lineStyle(StrokeStyle(lineWidth: 2.5))
        }
        .chartForegroundStyleScale(domain: viewModel.colorDomain, range: viewModel.colorRange)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 1))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartYScale(domain: .automatic(includesZero: false))
        .chartXScale(domain: viewModel.startDate...viewModel.endDate, type: .linear)
    }
    
    @ViewBuilder
    private var errorView: some View {
        if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text("Something went wrong")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: viewModel.userDidPressRetryAfterError) {
                    Text("Retry")
                        .font(.callout.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.secondary)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .shadow(radius: 8)
            .padding()
        }
    }
}
