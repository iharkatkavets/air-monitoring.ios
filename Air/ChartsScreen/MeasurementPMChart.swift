//
//  ParticlesCountChart.swift
//  Air
//
//  Created by Ihar Katkavets on 02/11/2025.
//

import SwiftUI
import Charts

struct MeasurementPMChart: View {
    let xAxisTitle: String
    let yAxisTitle: String
    let minValue: Double
    let maxValue: Double
    let values: [MeasurementMark]
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(xAxisTitle)
                .font(.subheadline)
            Chart(values) {
                LineMark(
                    x: .value(xAxisTitle, $0.date),
                    y: .value(yAxisTitle, $0.value)
                )
                .foregroundStyle(by: .value("Particle Size", $0.pmValue))
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel(centered: false) {
                        if let date = value.as(Date.self) {
                            Text(date.formatted(.dateTime.hour().minute().second()))
                        }
                    }
                    AxisTick(stroke: StrokeStyle(lineWidth: 1))
                        .foregroundStyle(Color.gray)

                    AxisGridLine(centered: false).foregroundStyle(.gray)
                }
            }
            .chartYScale(domain: minValue...maxValue)
            .chartScrollableAxes(.horizontal)
        }
    }
}
