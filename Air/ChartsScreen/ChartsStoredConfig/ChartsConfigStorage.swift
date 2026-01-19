//
//  ChartsStoredConfig.swift
//  Air
//
//  Created by Ihar Katkavets on 18/01/2026.
//

import Foundation

typealias SectionID = UUIDStr

struct ChartsConfigStorage {
    private struct Section: Codable {
        let id: SectionID
        let sensorID: SensorID
    }
    
    private struct Measurement: Codable {
        let id: UUIDStr
        let sectionID: SectionID
        let sensorMeasurement: SensorMeasurement
    }
    
    struct ChartsSectionConfig {
        let id: SectionID
        let sensorID: SensorID
        let measurements: [SensorMeasurement]
    }
    
    static let storage = UserDefaults.standard
    
    @UserDefaultsValue("ChartsConfigStorage.Sections")
    static private var sections: [Self.Section] = []
    
    @UserDefaultsValue("ChartsConfigStorage.Measurements")
    static private var measurements: [Self.Measurement] = []

    static func load() -> [ChartsSectionConfig] {
        let grouped = Dictionary(grouping: measurements, by: \.sectionID)
        
        return sections.map { section in
            ChartsSectionConfig(
                id: section.id,
                sensorID: section.sensorID,
                measurements: (grouped[section.id] ?? []).map(\.sensorMeasurement)
            )
        }
    }
    
    static func add(_ section: SectionID, _ sensorID: SensorID, _ mnts: [SensorMeasurement]) {
        sections.append(Section(id: section, sensorID: sensorID))
        
        let list = mnts.map {
            Measurement(id: UUID().uuidString, sectionID: section, sensorMeasurement: $0)
        }
        self.measurements.append( contentsOf: list)
    }
    
    static func removeMeasurement(_ measurement: SensorMeasurement, in section: SectionID) {
        measurements.removeAll {
            $0.sensorMeasurement == measurement && $0.sectionID == section
        }
    }
    
    static func removeSection(_ section: SectionID) {
        sections.removeAll { $0.id == section }
        measurements.removeAll { $0.sectionID == section }
    }
}
