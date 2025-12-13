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
    private var apiClient: APIClient
    @Published var errorMessage: String? = nil
    var loadMoreButtonTitle: String = "Load more"
    var loadingTask: Task<Void, Never>?
    let log = Logger()
    @Published var chartsViewModels = [Measurement: MeasurementChartViewModel]()
    let sensorID: SensorID
    private let measurements: [Measurement]
    let chartsCount: Int

    init(_ sensorID: SensorID, _ measurements: [Measurement]) {
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        self.sensorID = sensorID
        self.measurements = measurements
        self.chartsCount = measurements.count
        
        measurements.forEach {
            chartsViewModels[$0] = MeasurementChartViewModel(chartTitle: $0)
        }
    }
    
    func viewDidTriggerOnAppear() {
        if loadingTask == nil {
            fetchMeasurements()
        }
        else if apiClient.server != AppSettings.serverDomain {
            Task { await refresh() }
        }
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
                try Task.checkCancellation()
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
            let mark = MeasurementMark(date: v.timestamp, value: v.value, pmValue: parameter)
            vm?.yAxisTitle = v.unit
            vm?.append(mark)
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

