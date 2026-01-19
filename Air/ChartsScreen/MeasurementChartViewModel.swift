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
    var isLoading = true
    @ObservationIgnored
    private var colorsByParam: [String: Color] = [:]
    var colorDomain: [String] {
        colorsByParam.keys.sorted()
    }
    var colorRange: [Color] {
        colorDomain.map { colorsByParam[$0]! }
    }
    var errorMessage: String? = nil
    private let onRetryAction: ()->Void
    private let onCloseAction: (SensorMeasurement)->Void
    private let measurement: SensorMeasurement

    init(measurement: SensorMeasurement, chartTitle: String, onRetryAction: @escaping ()->Void, onDeleteAction: @escaping (SensorMeasurement)->Void) {
        self.measurement = measurement
        self.chartTitle = chartTitle
        self.onRetryAction = onRetryAction
        self.onCloseAction = onDeleteAction
    }
    
    func append(_ value: MeasurementMark, _ color: Color) {
        if value.date < endDate {
            return
        }
        isLoading = false
        values.append(value)
        endDate = max(endDate, value.date)
        startDate = endDate.addingTimeInterval(TimeInterval(-60))
        values.removeAll { $0.date < startDate }
        if colorsByParam[value.param] == nil {
            colorsByParam[value.param] = color
        }
    }
    
    func setError(_ message: String?) {
        errorMessage = message
    }
    
    func setIsLoading(_ value: Bool) {
        isLoading = value
    }
    
    func removeAll() {
        values.removeAll()
    }
    
    func userDidPressRetryAfterError() {
        onRetryAction()
    }
    
    func userDidPressCloseButton() {
        onCloseAction(measurement)
    }
}
