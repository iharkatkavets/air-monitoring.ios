//
//  MeasurementMark.swift
//  Air
//
//  Created by Ihar Katkavets on 02/11/2025.
//

import Foundation

typealias PMValue = String

struct MeasurementMark: Identifiable {
    let id: Int
    let date: Date
    let value: Double
    let pmValue: PMValue

    init(id: Int, date: Date, value: Double, pmValue: String) {
        self.id = id
        self.date = date
        self.value = value
        self.pmValue = pmValue
    }
}

