//
//  Color+Extension.swift
//  Air
//
//  Created by Ihar Katkavets on 17/12/2025.
//

import SwiftUI

fileprivate let availableColors: [Color] = [
    Color(hex: "#1F77B4"), // Blue
    Color(hex: "#FF7F0E"), // Orange
    Color(hex: "#2CA02C"), // Green
    Color(hex: "#D62728"), // Red
    Color(hex: "#9467BD"), // Purple
    Color(hex: "#17BECF"), // Cyan
    Color(hex: "#BCBD22"), // Olive
    Color(hex: "#E377C2"), // Pink
    Color(hex: "#8C564B"), // Brown
    Color(hex: "#7F7F7F")  // Gray
]

func chartColor(_ i: Int) -> Color {
    availableColors[i%availableColors.count]
}


extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)

        let r, g, b, a: Double
        switch hex.count {
        case 6: // RRGGBB
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
            a = 1.0
        case 8: // AARRGGBB
            a = Double((value >> 24) & 0xFF) / 255
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0; a = 1
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
