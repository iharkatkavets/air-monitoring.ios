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
        let id: SectionID
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
    @ObservationIgnored
    var heightPerChart: CGFloat = 300.0

    init() { }
    
    func viewDidTriggerOnAppear() {
        guard sections.isEmpty else {
            return
        }
        
        for section in ChartsConfigStorage.load() {
            addSection(section.id, section.sensorID, section.measurements)
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
    
    private func userDidSelectSensors(_ list: [(SensorID, SensorName, [SensorMeasurement])]) {
        sensorsListPopupIsPresented = false
        for (sensorID, _, measurements) in list {
            let sectionID = UUID().uuidString
            addSection(sectionID, sensorID, measurements)
            ChartsConfigStorage.add(sectionID, sensorID, measurements)
        }
    }
    
    private func addSection(_ sectionID: SectionID, _ sensorID: SensorID, _ measurements: [SensorMeasurement]) {
        let vm = ChartsGroupViewModel(
            sensorID,
            measurements,
            heightPerChart: heightPerChart,
            onDeleteMeasurementAction: { measurement in
                ChartsConfigStorage.removeMeasurement(measurement, in: sectionID)
            },
            onDeleteGroupAction: { [weak self] in
                ChartsConfigStorage.removeSection(sectionID)
                self?.sections.removeAll(where: { $0.id == sectionID })
            })
        sections.append(
            Section(
                id: sectionID,
                sensorID: sensorID,
                chartsCount: measurements.count,
                viewModel: vm
            )
        )
    }
}

