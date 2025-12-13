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
    let xAxisTitle: String = ""
    var yAxisTitle: String = ""
    var values: [MeasurementMark] = []
    var startDate: Date = Date().addingTimeInterval(TimeInterval(-60))
    var endDate: Date = .now
    var loadingTask: Task<Void, Never>?
    var isLoading = false

    init(chartTitle: String) {
        self.chartTitle = chartTitle
    }
    
    func append(_ value: MeasurementMark) {
        if value.date < endDate {
            return
        }
        values.append(value)
        endDate = max(endDate, value.date)
        startDate = endDate.addingTimeInterval(TimeInterval(-60))
        values.removeAll { $0.date < startDate }
    }
}
