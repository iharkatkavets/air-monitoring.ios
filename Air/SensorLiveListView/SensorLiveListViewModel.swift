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
    var displaySensors: [DisplaySensor] = []
    var isLoading: Bool = true
    var errorMessage: String?
    @ObservationIgnored
    private lazy var apiClient = APIClientImpl(server: AppSettings.serverDomain)
    @ObservationIgnored
    private var availableSensors: [SensorID: Sensor] = [:]
    var obsevationToken: AnyObject?
    @ObservationIgnored
    private var domainUpdatedTask: Task<Void, Never>?

    init() {
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
    
    func viewDidTriggerOnAppear() {
        Task {
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
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            errorMessage = nil
            displaySensors.removeAll(keepingCapacity: true)
            apiClient = APIClientImpl(server: AppSettings.serverDomain)
            let now = Date.now
            for s in try await apiClient.fetchSensors(){
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
        }
        catch {
            if !error.isCancellationError {
                self.errorMessage = error.message
            }
        }
    }
}
