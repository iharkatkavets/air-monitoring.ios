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
        VStack(alignment: .leading, spacing: 4) {
            Text(item.sensorName)
                .font(.headline)
            
            Text(item.sensorID)
                .font(.subheadline.monospaced())
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Spacer()
                Text("last seen:")
                Text(item.lastSeenTime.formatted(date: .numeric, time: .shortened))
                AvailabilityDot(isOnline: item.isOnline)
            }
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
                , isOnline: true
            ), measurements: [
                "mass_concentration",
                 "number_concentration",
                "typical_particle_size"
            ]
        )
    }
}
