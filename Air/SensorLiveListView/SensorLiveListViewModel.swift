//
//  SensorLiveListViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 25/01/2026.
//

import Foundation
import Combine

@Observable
final class SensorLiveListViewModel {
    enum State {
        case idle
        case loading
        case loaded([DisplaySensor])
        case failed(String)
    }
    var displaySensors: [DisplaySensor] = []
    var isLoading: Bool {
        if case .loading = state {
            return true
        } else {
            return false
        }
    }
    var errorMessage: String? {
        if case .failed(let errorMessage) = state {
            return errorMessage
        } else {
            return nil
        }
    }
    @ObservationIgnored
    private let apiClient: APIClient
    @ObservationIgnored
    private var availableSensors: [SensorID: Sensor] = [:]
    var obsevationToken: AnyObject?
    @ObservationIgnored
    private var domainUpdatedTask: Task<Void, Never>?
    var state: State = .idle

    init(_ apiClient: APIClient = APIClientImpl(server: AppSettings.serverDomain)) {
        self.apiClient = apiClient
        domainUpdatedTask = Task { [weak self] in
            let notificationCenter = NotificationCenter.default
            for await _ in notificationCenter.notifications(named: .domainUpdated, object: nil) {
                await self?.refresh()
            }
        }
    }
    
    deinit {
        domainUpdatedTask?.cancel()
    }
    
    func viewDidTriggerOnAppear() async {
        if case .idle = state {
            await fetchSensors()
        }
    }
    
    func refresh() async {
        await fetchSensors()
    }
    
    func makeSensorChartsViewModel(_ sensorID: SensorID) -> SensorChartsViewModel {
        SensorChartsViewModel(sensorID, availableSensors[sensorID]?.measurements ?? [])
    }
    
    private func fetchSensors() async {
        do {
            state = .loading
            displaySensors.removeAll(keepingCapacity: true)
            let now = Date.now
            for s in try await apiClient.fetchSensors() {
                availableSensors[s.sensorId] = s
                displaySensors.append(
                    DisplaySensor(
                        sensorID: s.sensorId,
                        sensorName: s.sensorName,
                        lastSeenTime: s.lastSeenTime,
                        measurements: s.measurements,
                        isOnline:  now.timeIntervalSince(s.lastSeenTime).isLess(than: AppSettings.storeInterval)
                    )
                )
            }
            state = .loaded(displaySensors)
        }
        catch {
            if !error.isCancellationError {
                state = .failed(error.message)
            }
        }
    }
}
