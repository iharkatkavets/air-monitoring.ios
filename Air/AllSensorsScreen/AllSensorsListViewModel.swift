//
//  AllSensorsListViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 12/12/2025.
//

import Combine
import Foundation


@MainActor
@Observable
final class AllSensorsListViewModel {
    struct DisplaySensor: Identifiable {
        var id: SensorID { sensorID }
        let sensorID: SensorID
        let sensorName: SensorName
        let lastSeenTime: Date
        let measurements: [Measurement]
        let isOnline: Bool
    }
    
    var displaySensors: [DisplaySensor] = []
    var isLoading: Bool = true
    var errorMessage: String?
    
    @ObservationIgnored
    private lazy var apiClient = APIClientImpl(server: AppSettings.serverDomain)
    @ObservationIgnored
    private var availableSensors: [Sensor] = []
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
    
    private func fetchSensors() async {
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            errorMessage = nil
            displaySensors.removeAll(keepingCapacity: true)
            apiClient = APIClientImpl(server: AppSettings.serverDomain)
            availableSensors = try await apiClient.fetchSensors()
            let now = Date.now
            for s in availableSensors {
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
