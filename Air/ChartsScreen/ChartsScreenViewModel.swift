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
    let particlesCountChartViewModel = MeasurementChartViewModel()
    let massDensityChartViewModel = MeasurementChartViewModel()

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
                print("start \(Date.now)")
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
                    particlesCountChartViewModel.chartTitle = "Particles Count, \(v.unit)"
                    particlesCountChartViewModel.latest[pmValue] = mark
                    particlesCountChartViewModel.values.append(mark)
                    particlesCountChartViewModel.xAxisTitle = "Particles Count, " + v.unit
                    particlesCountChartViewModel.endDate = max(particlesCountChartViewModel.endDate, v.timestamp)
                    log.info("particlesCount appended v.timestamp: \(v.timestamp)")
                }
            case "mass_density":
                if let pmValue = v.parameter {
                    let mark = MeasurementMark(id: v.id, date: v.timestamp, value: v.value, pmValue: pmValue)
                    massDensityChartViewModel.chartTitle = "Mass Density, \(v.unit)"
                    massDensityChartViewModel.latest[pmValue] = mark
                    massDensityChartViewModel.values.append(mark)
                    massDensityChartViewModel.xAxisTitle = "Mass Density, " + v.unit
                    massDensityChartViewModel.endDate = max(massDensityChartViewModel.endDate, v.timestamp)
                    log.info("massDensity appended v.timestamp: \(v.timestamp)")
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
