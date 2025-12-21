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

@MainActor
final class ChartsGroupViewModel: ObservableObject {
    var isLoading = false
    private lazy var apiClient: APIClient = APIClientImpl(server: AppSettings.serverDomain)
    @Published var errorMessage: String? = nil
    var loadMoreButtonTitle: String = "Load more"
    var loadingTask: Task<Void, Never>?
    let log = Logger()
    @Published var chartsViewModels = [Measurement: MeasurementChartViewModel]()
    let sensorID: SensorID
    private let measurements: [Measurement]
    let chartsCount: Int
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
    init(_ sensorID: SensorID, _ measurements: [Measurement]) {
        self.sensorID = sensorID
        self.measurements = measurements
        self.chartsCount = measurements.count
        
        measurements.forEach {
            chartsViewModels[$0] = MeasurementChartViewModel(chartTitle: $0)
        }
    }
    
    func viewDidTriggerOnAppear() {
        if loadingTask == nil || errorMessage != nil || loadingTask?.isCancelled == true {
            fetchMeasurements()
        }
    }
    
    func viewDidTriggerOnDisappear() {
        loadingTask?.cancel()
    }
    
    func fetchMeasurements() {
        loadingTask?.cancel()
        loadingTask = Task { [unowned self] in
            do {
                guard !isLoading else {
                    return
                }
                defer {
                    isLoading = false
                }
                errorMessage = nil
                isLoading = true
                for try await measurements in try await apiClient.fetchSensorStream(sensorID) {
                    try Task.checkCancellation()
                    appendValues(measurements)
                }
            }
            catch {
                if !error.isCancellationError {
                    errorMessage = (error as? APIClientError)?.message
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
    
    func refresh() async {
        errorMessage = nil
        loadingTask?.cancel()
        await loadingTask?.value
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        for (_, vm) in chartsViewModels {
            vm.values.removeAll()
        }
        fetchMeasurements()
    }
    
    func userDidPressTryAgain() {
        errorMessage = nil
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        fetchMeasurements()
    }
}

