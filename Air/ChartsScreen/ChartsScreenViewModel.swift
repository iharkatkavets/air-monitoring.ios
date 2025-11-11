//
//  ChartsScreenViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 01/11/2025.
//

import Combine
import Foundation

@MainActor
final class ChartsScreenViewModel: ObservableObject {
    @Published var particlesCount: [MeasurementMark] = []
    @Published var particlesCountMinValue: Double = 0
    @Published var particlesCountMaxValue: Double = 0
    private var particlesCountMinValueInternal: Double = 1000
    private var particlesCountMaxValueInternal: Double = 0
    @Published var massDensity: [MeasurementMark] = []
    @Published var massDensityMinValue: Double = 0
    @Published var massDensityMaxValue: Double = 0
    private var massDensityMinValueInternal: Double = 1000
    private var massDensityMaxValueInternal: Double = 0
    var isLoading = false
    private var apiClient: APIClient
    @Published var errorMessage: String? = nil
    var loadMoreButtonTitle: String = "Load more"
    var loadingTask: Task<Void, Never>?
    
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
                    let padding = 5.0
                    if v.value < particlesCountMinValueInternal {
                        particlesCountMinValueInternal = v.value-padding
                        particlesCountMinValue = particlesCountMinValueInternal
                    }
                    if v.value > particlesCountMaxValueInternal {
                        particlesCountMaxValueInternal = v.value+padding
                        particlesCountMaxValue = particlesCountMaxValueInternal
                    }
                    particlesCount.append(MeasurementMark(id: v.id, date: v.timestamp, value: v.value, pmValue: pmValue))
                }
            case "mass_density":
                if let pmValue = v.parameter {
                    let padding = 5.0
                    if v.value < massDensityMinValueInternal {
                        massDensityMinValueInternal = v.value-padding
                        massDensityMinValue = massDensityMinValueInternal
                    }
                    if v.value > massDensityMaxValueInternal {
                        massDensityMaxValueInternal = v.value+padding
                        massDensityMaxValue = massDensityMaxValueInternal
                    }
                    massDensity.append(MeasurementMark(id: v.id, date: v.timestamp, value: v.value, pmValue: pmValue))
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
        particlesCount.removeAll()
        massDensity.removeAll()
        fetchMeasurements()
    }
    
    func userDidPressTryAgain() {
        errorMessage = nil
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        fetchMeasurements()
    }
}
