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
//    @Binding var showInfo: Bool
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            chartHeader
            chart
        }
    }
    
    var chartHeader: some View {
        HStack(spacing: 8) {
            yAxisTitle
            Spacer()
            chartTitle
            Spacer()
            Color.clear.frame(width: 16, height: 16)
//            infoButton
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
    
    var infoButton: some View {
        Button {
//            showInfo = true
        } label: {
            Image(systemName: "info.circle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary.opacity(0.8))
                .symbolRenderingMode(.hierarchical)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
}
