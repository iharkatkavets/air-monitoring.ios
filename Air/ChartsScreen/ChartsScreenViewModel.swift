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
final class ChartsScreenViewModel: ObservableObject {
    var isLoading = false
    private lazy var apiClient = APIClientImpl(server: AppSettings.serverDomain)
    @Published var errorMessage: String? = nil
    var loadMoreButtonTitle: String = "Load more"
    let log = Logger()
    @Published var sensorsListPopupIsPresented: Bool = false
    lazy var sensorsListPopupViewModel =
    SelectableSensorsListViewModel(onError: { [weak self] in
        self?.errorMessage = $0.message
    }, onSelectSensors: { [weak self]  in
        self?.userDidSelectSensors($0)
    })
    @Published var sensors: [(UUID, SensorID, Int, ChartsGroupViewModel)] = []

    init() {
    }
    
    func viewDidTriggerOnAppear() {
        guard sensors.isEmpty else {
            return
        }
        
        for config in AppSettings.sensors {
            sensors.append(
                (UUID(), config.id, config.measurements.count, ChartsGroupViewModel(config.id, config.measurements))
            )
        }
    }
    
    func refresh() async {
        errorMessage = nil
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
    }
    
    func userDidPressTryAgain() {
        errorMessage = nil
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
    }
    
    func userDidPressAddSensor() {
        sensorsListPopupIsPresented = true
    }
    
    private func userDidSelectSensors(_ list: [(SensorID, SensorName, [Measurement])]) {
        sensorsListPopupIsPresented = false
        for (id, _, measurements) in list {
            sensors.append((UUID(), id, measurements.count, ChartsGroupViewModel(id, measurements)))
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

