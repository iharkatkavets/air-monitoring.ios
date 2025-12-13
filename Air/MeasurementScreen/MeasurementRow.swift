//
//  MeasurementRow.swift
//  Air
//
//  Created by Ihar Katkavets on 19/10/2025.
//

import SwiftUI

// Reusable custom row
struct MeasurementRow: View {
    let item: MeasurementData
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.measurement)
                    .font(.headline)
                if let parameter = item.parameter, !parameter.isEmpty {
                    Text(parameter)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(item.timestamp.formatted(date: .numeric, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(item.value.formatted()) \(item.unit)")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(Color.secondary.opacity(0.12))
                    )
                
                Text("#\(item.id)")
                    .foregroundStyle(.tertiary)
                    .font(.caption2.monospacedDigit())
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
        .contentShape(Rectangle())
    }
}

#Preview {
    MeasurementRow(
        item: .init(
            id: 11,
            sensorName: "sps30",
            measurement: "particle_count",
            parameter: "pm4.0",
            value: 28.049,
            unit: "#/cm3",
            timestamp: .now,
            createdAt: .now
        )
    )
}
