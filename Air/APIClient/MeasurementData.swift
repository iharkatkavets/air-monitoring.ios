//
//  Measurement.swift
//  Air
//
//  Created by Ihar Katkavets on 19/10/2025.
//

import Foundation

struct MeasurementData: Decodable, Identifiable {
    let id: Int
    let sensorName: String
    let measurement: String
    let parameter: String?
    let value: Double
    let unit: String
    let timestamp: Date
    let createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, parameter, value, unit, timestamp, measurement
        case createdAt = "created_at"
        case sensorName = "sensor_name"
    }
}

struct MeasurementSSE: Decodable, Hashable, Identifiable {
    var id: Self { self }
    let sensorName: String
    let measurement: String
    let parameter: String?
    let value: Double
    let unit: String
    let timestamp: Date
    
    private enum CodingKeys: String, CodingKey {
        case parameter, value, unit, timestamp, measurement
        case sensorName = "sensor_name"
    }
}
