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
    lazy var chartsScreenViewModel = SelectedChartsViewModel()
    @ObservationIgnored
    lazy var sensorHistoryListViewModel = SensorHistoryListViewModel()
    @ObservationIgnored
    lazy var sensorLiveListViewModel = SensorLiveListViewModel()
    @ObservationIgnored
    private var domainUpdatedTask: Task<Void, Never>?
    let popToRoot = PassthroughSubject<Void, Never>()

    init() { }
    
    func viewDidTriggerOnAppear() {
        domainUpdatedTask = Task { [weak self] in
            let notificationCenter = NotificationCenter.default
            for await _ in notificationCenter.notifications(named: .domainUpdated, object: nil) {
                self?.popToRoot.send()
            }
        }
    }
}
