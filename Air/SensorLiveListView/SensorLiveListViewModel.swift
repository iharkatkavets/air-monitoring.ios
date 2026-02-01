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
    var displaySensors: [DisplaySensor] {
        if case .loaded(let array) = state {
            return array
        } else {
            return []
        }
    }
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
            let now = Date.now
            var fetchedSensors = try await apiClient.fetchSensors()
            fetchedSensors.sort { $0.sensorId < $1.sensorId }
            var sensors = [DisplaySensor]()
            for s in fetchedSensors {
                availableSensors[s.sensorId] = s
                sensors.append(
                    DisplaySensor(
                        sensorID: s.sensorId,
                        sensorName: s.sensorName,
                        lastSeenTime: s.lastSeenTime,
                        measurements: s.measurements,
                        isOnline:  now.timeIntervalSince(s.lastSeenTime).isLess(than: AppSettings.storeInterval)
                    )
                )
            }
            state = .loaded(sensors)
        }
        catch {
            if !error.isCancellationError {
                state = .failed(error.message)
            }
        }
    }
}
