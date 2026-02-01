//
//  ChartsGroupViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 08/12/2025.
//

import SwiftUI
import Foundation
import Combine
import os.log

final class ChartsGroupViewModel: ObservableObject {
    private let apiClient: APIClient
    var loadingTask: Task<Void, Never>?
    let log = Logger()
    @Published var chartsViewModels = [SensorMeasurement: MeasurementChartViewModel]()
    let sensorID: SensorID
    private let measurements: [SensorMeasurement]
    @Published var chartsCount: Int
    private var assignedColors = [String: Color]()
    private var isFetchErrorOccured = true
    var height: CGFloat
    private let heightPerChart: CGFloat
    private let onDeleteMeasurementAction: (SensorMeasurement)->Void
    private let onDeleteGroupAction: ()->Void

    init(_ sensorID: SensorID,
         _ measurements: [SensorMeasurement],
         heightPerChart: CGFloat,
         apiClient: APIClient = APIClientImpl(server: AppSettings.serverDomain),
         onDeleteMeasurementAction: @escaping (SensorMeasurement)->Void,
         onDeleteGroupAction: @escaping ()->Void) {
        self.sensorID = sensorID
        self.measurements = measurements
        self.chartsCount = measurements.count
        self.apiClient = apiClient
        self.heightPerChart = heightPerChart
        self.onDeleteMeasurementAction = onDeleteMeasurementAction
        self.onDeleteGroupAction = onDeleteGroupAction
        self.height = CGFloat(measurements.count)*heightPerChart
        
        measurements.forEach {
            chartsViewModels[$0] = MeasurementChartViewModel(
                measurement: $0,
                chartTitle: $0,
                onRetryAction: { [weak self] in
                    self?.userDidPressTryAgain()
                },
                onDeleteAction: { [weak self] in
                    self?.userDidPressDeleteMeasurement($0)
                })
        }
    }
    
    deinit {
        loadingTask?.cancel()
    }
    
    func viewDidTriggerOnAppear() {
        if loadingTask == nil || isFetchErrorOccured || loadingTask?.isCancelled == true {
            fetchMeasurements()
        }
    }
    
    func viewDidTriggerOnDisappear() {
        loadingTask?.cancel()
    }
    
    func fetchMeasurements() {
        loadingTask?.cancel()
        loadingTask = Task { [weak self, apiClient, sensorID] in
            defer {
                self?.setIsLoading(false)
                self?.loadingTask = nil
            }
            do {
                self?.setIsLoading(true)
                self?.setError(nil)
                for try await measurements in try await apiClient.fetchSensorStream(sensorID, 15) {
                    try Task.checkCancellation()
                    self?.appendValues(measurements)
                }
            }
            catch {
                if !error.isCancellationError {
                    self?.setError((error as? APIClientError)?.message)
                }
            }
        }
    }
    
    private func appendValues(_ values: [MeasurementSSE]) {
        for v in values {
            let measurement = v.measurement.lowercased()
            let vm = chartsViewModels[measurement]
            let parameter = v.parameter ?? ""
            let color = assignedColors[parameter, default: chartColor(assignedColors.count)]
            assignedColors[parameter] = color
            let mark = MeasurementMark(date: v.timestamp, value: v.value, parameter: parameter, color: color)
            vm?.yAxisTitle = v.unit
            vm?.append(mark, color)
        }
    }
    
    private func setError(_ message: String?) {
        isFetchErrorOccured = message != nil
        for (_, vm) in chartsViewModels {
            vm.setError(message)
        }
    }
    
    private func setIsLoading(_ value: Bool) {
        for (_, vm) in chartsViewModels {
            vm.setIsLoading(value)
        }
    }
    
    func refresh() async {
        isFetchErrorOccured = false
        loadingTask?.cancel()
        await loadingTask?.value
        for (_, vm) in chartsViewModels {
            vm.removeAll()
        }
        fetchMeasurements()
    }
    
    private func userDidPressTryAgain() {
        fetchMeasurements()
    }
    
    private func userDidPressDeleteMeasurement(_ measurement: SensorMeasurement) {
        chartsViewModels[measurement] = nil
        chartsCount = chartsViewModels.count
        height = CGFloat(chartsViewModels.count)*heightPerChart
        onDeleteMeasurementAction(measurement)
        if chartsCount == 0 {
            onDeleteGroupAction()
        }
    }
}

