//
//  Measurement.swift
//  Air
//
//  Created by Ihar Katkavets on 19/10/2025.
//

import Foundation


struct Measurement: Decodable, Identifiable {
    let id: Int
    let sensor: String
    let parameter: String?
    let value: Double
    let unit: String
    let timestamp: Date
    let createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, sensor, parameter, value, unit, timestamp
        case createdAt = "created_at"
    }
}

struct MeasurementSSE: Decodable, Hashable, Identifiable {
    var id: Self { self }
    let sensor: String
    let parameter: String?
    let value: Double
    let unit: String
    let timestamp: Date
    let createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case sensor, parameter, value, unit, timestamp
        case createdAt = "created_at"
    }
}
