//
//  ChartsScreenViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 01/11/2025.
//

import Combine
import Foundation
import os.log

@MainActor
final class ChartsScreenViewModel: ObservableObject {
    var isLoading = false
    private var apiClient: APIClient
    @Published var errorMessage: String? = nil
    var loadMoreButtonTitle: String = "Load more"
    var loadingTask: Task<Void, Never>?
    let log = Logger()
    let particlesCountChartViewModel = MeasurementChartViewModel(chartTitle: "Number concentration")
    let massDensityChartViewModel = MeasurementChartViewModel(chartTitle: "Mass concentration")

    init() {
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
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
                for try await measurements in try await apiClient.fetchMeasurementStream() {
                    try Task.checkCancellation()
                    appendValues(measurements)
                }
            }
            catch {
                if error.isCancellationError {
                    return
                }
                errorMessage = (error as? APIClientError)?.message
            }
        }
    }
    
    private func appendValues(_ values: [Measurement]) {
        for v in values {
            switch v.sensor.lowercased() {
            case "particle_count":
                if let pmValue = v.parameter {
                    let mark = MeasurementMark(id: v.id, date: v.timestamp, value: v.value, pmValue: pmValue)
                    particlesCountChartViewModel.yAxisTitle = v.unit
                    particlesCountChartViewModel.append(mark)
                }
            case "mass_density":
                if let pmValue = v.parameter {
                    let mark = MeasurementMark(id: v.id, date: v.timestamp, value: v.value, pmValue: pmValue)
                    massDensityChartViewModel.yAxisTitle = v.unit
                    massDensityChartViewModel.append(mark)
                }
            default:
                continue
            }
        }
        
    }
    
    func refresh() async {
        errorMessage = nil
        loadingTask?.cancel()
        await loadingTask?.value
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        particlesCountChartViewModel.values.removeAll()
        massDensityChartViewModel.values.removeAll()
        fetchMeasurements()
    }
    
    func userDidPressTryAgain() {
        errorMessage = nil
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        fetchMeasurements()
    }
}
