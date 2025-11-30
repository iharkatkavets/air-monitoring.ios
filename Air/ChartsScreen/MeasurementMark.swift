//
//  MeasurementMark.swift
//  Air
//
//  Created by Ihar Katkavets on 02/11/2025.
//

import Foundation

typealias PMValue = String

struct MeasurementMark: Hashable, Identifiable {
    var id: Self { self }
    let date: Date
    let value: Double
    let pmValue: PMValue

    init(date: Date, value: Double, pmValue: String) {
        self.date = date
        self.value = value
        self.pmValue = pmValue
    }
}

