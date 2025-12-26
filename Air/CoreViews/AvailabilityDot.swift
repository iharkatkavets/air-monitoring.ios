//
//  AvailabilityDot.swift
//  Air
//
//  Created by Ihar Katkavets on 26/12/2025.
//

import SwiftUI

struct AvailabilityDot: View {
    let isOnline: Bool
    
    var body: some View {
        Circle()
            .fill(isOnline ? Color.green : Color.red)
            .frame(width: 8, height: 8)
    }
}

#Preview {
    AvailabilityDot(isOnline: true)
}
