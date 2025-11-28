//
//  MeasurementChartViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 27/11/2025.
//

import Combine
import SwiftUI

@Observable
final class MeasurementChartViewModel {
    var chartTitle: String = ""
    var xAxisTitle: String = ""
    var yAxisTitle: String = ""
    var values: [MeasurementMark] = []
    var startDate: Date = .now
    var endDate: Date = .now
    var latest: [PMValue: MeasurementMark] = [:]
}
