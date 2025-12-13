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
    }
    
    var displaySensors: [DisplaySensor] = []
    var isLoading: Bool = false
    var error: String?
    
    @ObservationIgnored
    private lazy var apiClient = APIClientImpl(server: AppSettings.serverDomain)
    @ObservationIgnored
    private var availableSensors: [Sensor] = []

    init() { }
    
    func viewDidTriggerOnAppear() async {
        await fetchSensors()
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
            displaySensors.removeAll(keepingCapacity: true)
            availableSensors = try await apiClient.fetchSensors()
            for s in availableSensors {
                displaySensors.append(
                    DisplaySensor(
                        sensorID: s.sensorId,
                        sensorName: s.sensorName,
                        lastSeenTime: s.lastSeenTime,
                        measurements: s.measurements
                    )
                )
            }
        }
        catch {
            if !error.isCancellationError {
                self.error = error.message
            }
        }
    }
    
}

