//
//  SensorRow.swift
//  Air
//
//  Created by Ihar Katkavets on 12/12/2025.
//

import SwiftUI

struct SensorRow: View {
    let item: AllSensorsListViewModel.DisplaySensor
    let measurements: [String]
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.sensorName)
                    .font(.headline)
                Text(item.sensorID)
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(item.lastSeenTime.formatted(date: .numeric, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
    
#Preview {
    ZStack {
        Color.black
        SensorRow(
            item: AllSensorsListViewModel.DisplaySensor(
                sensorID: "",
                sensorName: "",
                lastSeenTime: Date(),
                measurements: [
                    "mass_concentration",
                    "number_concentration",
                    "typical_particle_size"
                ]
            ), measurements: [
                "mass_concentration",
                 "number_concentration",
                "typical_particle_size"
            ]
        )
    }
}
