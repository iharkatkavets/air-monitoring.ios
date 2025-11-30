//
//  MeasurementChartViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 27/11/2025.
//

import Combine
import SwiftUI

@Observable
final class MeasurementChartViewModel {
    let chartTitle: String
    var xAxisTitle: String = ""
    var yAxisTitle: String = ""
    var values: [MeasurementMark] = []
    var startDate: Date = .distantPast
    var endDate: Date = .now
    var latest: [PMValue: MeasurementMark] = [:]
    
    init(chartTitle: String) {
        self.chartTitle = chartTitle
    }
    
    func append(_ value: MeasurementMark) {
        if value.date < endDate {
            return
        }
        values.append(value)
        latest[value.pmValue, default: value] = value
        endDate = max(endDate, value.date)
        let lowBound = endDate.addingTimeInterval(TimeInterval(-60))
        startDate = max(lowBound, values.first!.date)
        values.removeAll { $0.date < startDate }
    }
}
