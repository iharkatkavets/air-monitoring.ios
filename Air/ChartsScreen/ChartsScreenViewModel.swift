//
//  ChartsScreenViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 01/11/2025.
//

import Combine
import Foundation
import os.log
import Collections

@MainActor
@Observable
final class ChartsScreenViewModel {
    struct Section: Identifiable {
        let id: UUID
        let sensorID: SensorID
        let chartsCount: Int
        let viewModel: ChartsGroupViewModel
    }
    var isLoading = true
    var errorMessage: String? = nil
    var loadMoreButtonTitle: String = "Load more"
    let log = Logger()
    var sensorsListPopupIsPresented: Bool = false
    @ObservationIgnored
    lazy var sensorsListPopupViewModel = SelectableSensorsListViewModel(
        onError: { [weak self] in
            self?.errorMessage = $0.message
        }, onSelectSensors: { [weak self]  in
            self?.userDidSelectSensors($0)
        })
    var sections = [Section]()

    init() { }
    
    func viewDidTriggerOnAppear() {
        guard sections.isEmpty else {
            return
        }
        
        for config in AppSettings.sensors {
            sections.append(
                Section(id: UUID(), sensorID: config.id, chartsCount: config.measurements.count, viewModel: ChartsGroupViewModel(config.id, config.measurements))
            )
        }
    }
    
    func refresh() async {
        errorMessage = nil
    }
    
    func userDidPressTryAgain() {
        errorMessage = nil
    }
    
    func userDidPressAddSensor() {
        sensorsListPopupIsPresented = true
    }
    
    private func userDidSelectSensors(_ list: [(SensorID, SensorName, [Measurement])]) {
        sensorsListPopupIsPresented = false
        for (id, _, measurements) in list {
            sections.append(Section(id: UUID(), sensorID:id, chartsCount: measurements.count, viewModel: ChartsGroupViewModel(id, measurements)))
        }
        
        Task {
            var config = [AppSettings.SensorConfig]()
            for (id, name, measurements) in list {
                config.append(.init(id: id, name: name, measurements: measurements))
            }
            AppSettings.sensors += config
        }
    }
}

