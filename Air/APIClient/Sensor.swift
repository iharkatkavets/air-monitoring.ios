//
//  Sensor.swift
//  Air
//
//  Created by Ihar Katkavets on 07/12/2025.
//

import Foundation

struct Sensor: Hashable, Identifiable {
    var id: SensorID { sensorId }
    let sensorId: SensorID
    let sensorName: SensorName
    let lastSeenTime: Date
    let measurements: [Measurement]
}
