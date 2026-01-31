//
//  SensorChartsViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 25/01/2026.
//

import Foundation
import Combine
import os.log
import SwiftUI
import Synchronization

@Observable
final class SensorChartsViewModel: Sendable {
    var isLoading = true
    var errorMessage: String? = nil
    @ObservationIgnored
    private lazy var apiClient: APIClient = APIClientImpl(server: AppSettings.serverDomain)
    var loadingTask: Task<Void, Never>?
    let log = Logger()
    var chartsViewModels = [SensorMeasurement: MeasurementChartViewModel]()
    @ObservationIgnored
    let sensorID: SensorID
    private let measurements: [SensorMeasurement]
    var chartsCount: Int
    @ObservationIgnored
    private var assignedColors = [String: Color]()
    let availableColors: [Color] = [
        Color(hex: "#1F77B4"), // Blue
        Color(hex: "#FF7F0E"), // Orange
        Color(hex: "#2CA02C"), // Green
        Color(hex: "#D62728"), // Red
        Color(hex: "#9467BD"), // Purple
        Color(hex: "#17BECF"), // Cyan
        Color(hex: "#BCBD22"), // Olive
        Color(hex: "#E377C2"), // Pink
        Color(hex: "#8C564B"), // Brown
        Color(hex: "#7F7F7F")  // Gray
    ]
    private var isFetchErrorOccured = true

    init(_ sensorID: SensorID,
         _ measurements: [SensorMeasurement]) {
        self.sensorID = sensorID
        self.measurements = measurements
        self.chartsCount = measurements.count
        
        measurements.forEach {
            let vm = MeasurementChartViewModel(
                measurement: $0,
                chartTitle: $0,
                closeAvailable: false,
                onRetryAction: { [weak self] in
                    self?.userDidPressTryAgain()
                },
                onDeleteAction: { _ in })
            chartsViewModels[$0] = vm
        }
    }
    
    isolated deinit {
        self.loadingTask?.cancel()
    }

    func userDidPressTryAgain() {
        errorMessage = nil
    }
    
    func viewDidTriggerOnAppear() async {
        if loadingTask == nil {
            await refresh()
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
            let color = assignedColors[parameter, default: availableColors[assignedColors.count]]
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
        isLoading = value
        for (_, vm) in chartsViewModels {
            vm.setIsLoading(value)
        }
    }
    
    func refresh() async {
        isFetchErrorOccured = false
        loadingTask?.cancel()
        await loadingTask?.value
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        for (_, vm) in chartsViewModels {
            vm.removeAll()
        }
        fetchMeasurements()
    }
}
