//
//  SensosListViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 11/12/2025.
//

import Combine
import SwiftUI

@MainActor
final class SelectableSensorsListViewModel: ObservableObject {
    struct DisplaySensor: Hashable, Identifiable {
        var id: SensorID { sensorId }
        let sensorId: SensorID
        let sensorName: SensorName
        let lastSeenTime: Date
        let measurements: [[String]] // [[measurement_id, measurement]]
        let isOnline: Bool
    }
    
    private var availableSensors = [Sensor]()
    var displaySensors = [DisplaySensor]()
    private lazy var apiClient = APIClientImpl(server: AppSettings.serverDomain)
    private let onError: (APIClientError) -> Void
    private let onSelectSensors: ([(SensorID, SensorName, [SensorMeasurement])]) -> Void
    @Published var selectedSensors = Set<SensorID>()
    @Published var isLoading = false
    
    init(onError: @escaping (APIClientError) -> Void, onSelectSensors: @escaping ([(SensorID, SensorName, [SensorMeasurement])]) -> Void) {
        self.onError = onError
        self.onSelectSensors = onSelectSensors
    }
    
    func viewDidTriggerOnAppear() async {
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            displaySensors.removeAll(keepingCapacity: true)
            selectedSensors.removeAll()
            availableSensors = try await apiClient.fetchSensors()
            let now = Date.now
            for s in availableSensors {
                displaySensors.append(
                    DisplaySensor(
                        sensorId: s.sensorId,
                        sensorName: s.sensorName,
                        lastSeenTime: s.lastSeenTime,
                        measurements: s.measurements
                            .map( { [ s.sensorId + "." + $0, $0 ] }),
                        isOnline: now.timeIntervalSince(s.lastSeenTime).isLess(than: AppSettings.storeInterval)
                    )
                )
            }
        }
        catch {
            if !error.isCancellationError {
                onError(error)
            }
        }
    }
    
    func userDidPressDone() {
        var id2SensorIDMap = [String: SensorID]()
        var sensorID2SensorMap = [SensorID: (SensorName, [SensorMeasurement])]()
        for sensor in availableSensors {
            for measurement in sensor.measurements {
                id2SensorIDMap[sensor.sensorId + "." + measurement] = sensor.sensorId
            }
            id2SensorIDMap[sensor.sensorId] = sensor.sensorId
            sensorID2SensorMap[sensor.sensorId] = (sensor.sensorName, sensor.measurements)
        }
        var resultIDs = [SensorID: [SensorMeasurement]]()
        for id in selectedSensors {
            let foundId = id2SensorIDMap[id]!
            let hasMeasurement = id.hasPrefix(foundId + ".")
            let measurement = hasMeasurement ? id.dropFirst(foundId.count + 1) : ""
            if measurement.isEmpty {
                resultIDs[foundId, default: []] += []
            } else {
                resultIDs[foundId, default: []] += [String(measurement)]
            }
        }
        var result = [(SensorID, SensorName, [SensorMeasurement])]()
        for (key, selectedMeasurements) in resultIDs {
            let (sensorName, allMeasurements) = sensorID2SensorMap[key]!
            if selectedMeasurements.isEmpty {
                result.append((key, sensorName, allMeasurements))
            } else {
                result.append((key, sensorName, selectedMeasurements))
            }
        }
        onSelectSensors(result)
    }
}
