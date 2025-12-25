//
//  SensorRow.swift
//  Air
//
//  Created by Ihar Katkavets on 07/12/2025.
//

import SwiftUI

struct SelectableSensorRow: View {
    let item: SelectableSensorsListViewModel.DisplaySensor
    let measurements: [[String]]
    
    var body: some View {
        DisclosureGroup {
            ForEach(measurements, id: \.[0]) { m in
                HStack {
                    Text(m[1])
                    Spacer()
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.sensorName)
                    .font(.headline)
                Text(item.sensorId)
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Spacer()
                    Text(item.lastSeenTime.formatted(date: .numeric, time: .shortened))
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    availabilityDot
                }
            }
        }
    }
    
    private var availabilityDot: some View {
        Circle()
            .fill(item.isOnline ? .green : .red)
            .frame(width: 12, height: 12)
    }
}
    
#Preview {
    ZStack {
        Color.black
        SelectableSensorRow(
            item: SelectableSensorsListViewModel.DisplaySensor(
                sensorId: "",
                sensorName: "",
                lastSeenTime: Date(),
                measurements: [
                    ["sps30.pizero.mass_concentration", "mass_concentration"],
                    ["sps30.pizero.mass_concentration", "number_concentration"],
                    ["sps30.pizero.mass_concentration", "typical_particle_size"]
                ],
                isOnline: true
            ), measurements: [
                ["sps30.pizero.mass_concentration", "mass_concentration"],
                ["sps30.pizero.mass_concentration", "number_concentration"],
                ["sps30.pizero.mass_concentration", "typical_particle_size"]
            ]
        )
    }
}
