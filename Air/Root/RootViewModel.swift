//
//  RootViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 24/12/2025.
//

import Foundation
import Combine

enum TabTag: Hashable {
    case sensors, charts, settings
}

@Observable
final class RootViewModel {
    @ObservationIgnored
    lazy var settingsViewModel = SettingsScreenViewModel()
    @ObservationIgnored
    lazy var chartsScreenViewModel = ChartsScreenViewModel()
    @ObservationIgnored
    lazy var sensorHistoryListViewModel = SensorHistoryListViewModel()
    @ObservationIgnored
    lazy var sensorLiveListViewModel = SensorLiveListViewModel()
    
    init() { }
}
