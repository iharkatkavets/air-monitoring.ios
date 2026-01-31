//
//  DisplaySensor.swift
//  Air
//
//  Created by Ihar Katkavets on 25/01/2026.
//

import Foundation

struct DisplaySensor: Identifiable {
    var id: SensorID { sensorID }
    let sensorID: SensorID
    let sensorName: SensorName
    let lastSeenTime: Date
    let measurements: [SensorMeasurement]
    let isOnline: Bool
}

