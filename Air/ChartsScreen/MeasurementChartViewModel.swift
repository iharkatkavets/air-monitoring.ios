//
//  MeasurementChartViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 27/11/2025.
//

import Combine
import SwiftUI
import Charts

@Observable
final class MeasurementChartViewModel {
    let chartTitle: String
    let xAxisTitle: String = ""
    var yAxisTitle: String = ""
    var values: [MeasurementMark] = []
    var startDate: Date = Date().addingTimeInterval(TimeInterval(-60))
    var endDate: Date = .now
    var isLoading = false
    @ObservationIgnored
    private var colorsByParam: [String: Color] = [:]
    var colorDomain: [String] {
        colorsByParam.keys.sorted()
    }
    var colorRange: [Color] {
        colorDomain.map { colorsByParam[$0]! }
    }

    init(chartTitle: String) {
        self.chartTitle = chartTitle
    }
    
    func append(_ value: MeasurementMark, _ color: Color) {
        if value.date < endDate {
            return
        }
        values.append(value)
        endDate = max(endDate, value.date)
        startDate = endDate.addingTimeInterval(TimeInterval(-60))
        values.removeAll { $0.date < startDate }
        if colorsByParam[value.param] == nil {
            colorsByParam[value.param] = color
        }
    }
}
