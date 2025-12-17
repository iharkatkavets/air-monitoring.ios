//
//  MeasurementMark.swift
//  Air
//
//  Created by Ihar Katkavets on 02/11/2025.
//

import Foundation
import SwiftUI

struct MeasurementMark: Hashable, Identifiable {
    var id: Self { self }
    let date: Date
    let value: Double
    let param: String
    let color: Color

    init(date: Date, value: Double, parameter: String, color: Color) {
        self.date = date
        self.value = value
        self.param = parameter
        self.color = color
    }
}

