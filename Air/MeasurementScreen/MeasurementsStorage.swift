//
//  MeasurementsStorage.swift
//  Air
//
//  Created by Ihar Katkavets on 02/11/2025.
//

import SwiftData
import Foundation

protocol MeasurementsStorage {
}

@Model
final class MeasurementEntity: Identifiable {
    var id: Int
    var date: Date
    
    init(id: Int, date: Date) {
        self.id = id
        self.date = date
    }
    
    func toMeasurementLite() -> MeasurementLite {
        return .init(id: id)
    }
    
}

struct MeasurementLite: Identifiable {
    var id: Int
}


actor MeasurementsStorageImp: MeasurementsStorage {
    init() throws {
        let schema = Schema([
            MeasurementEntity.self,
        ])

        let configuration = ModelConfiguration(schema: schema)
        self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
    }

    private let modelContainer: ModelContainer
}

extension MeasurementsStorageImp {
    func fetchMeasurements() throws -> [MeasurementLite] {
        try performOperation { context in
            let descriptor = FetchDescriptor<MeasurementEntity>(
                sortBy: [SortDescriptor(\.date, order: .forward)]
            )

            let models = try context.fetch(descriptor)
            return models.map { $0.toMeasurementLite() }
        }
    }

    func saveMeasurement(_ measurement: MeasurementLite) throws {
        try performOperation { context in
            let id = measurement.id
            let descriptor = FetchDescriptor<MeasurementEntity>(
                predicate: #Predicate { $0.id == id  }
            )
            if let existing = try context.fetch(descriptor).first {
            } else {
                let newModel = MeasurementEntity(id: measurement.id, date: Date())
                context.insert(newModel)
            }
            try context.save()
        }
    }

    func deleteMeasurementWith(id: Int) throws {
        try performOperation { context in
            let descriptor = FetchDescriptor<MeasurementEntity>(
                predicate: #Predicate { $0.id == id }
            )
            for model in try context.fetch(descriptor) { context.delete(model) }
            try context.save()
        }
    }
}

private extension MeasurementsStorageImp {
    func performOperation<T>(_ operation: (ModelContext) throws -> T) rethrows -> T {
        let context = ModelContext(modelContainer)
        return try operation(context)
    }
}
