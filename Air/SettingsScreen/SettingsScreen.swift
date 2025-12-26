//
//  SettingsScreen.swift
//  Air
//
//  Created by Ihar Katkavets on 29/10/2025.
//

import SwiftUI

struct SettingsScreen: View {
    enum ActiveSheet: Identifiable {
        case maxAge(DurationSeconds)
        case storeInterval(DurationSeconds)
        
        var title: String {
            switch self {
            case .maxAge: return "Max Age"
            case .storeInterval: return "Store Interval"
            }
        }
        
        var id: Int {
            switch self {
            case .maxAge:
                return 0
            case .storeInterval:
                return 1
            }
        }
        
        var configuration: DurationPicker.Configuration {
            switch self {
            case .maxAge:
                return DurationPicker.Configuration(numbers: 1...60, units: ["d"])
            case .storeInterval:
                return DurationPicker.Configuration(numbers: 1...60, units: ["s","m"])
            }
        }
        
        var defaultValue: DurationSeconds {
            switch self {
            case .maxAge(let defaultValue):
                return defaultValue
            case .storeInterval(let defaultValue):
                return defaultValue
            }
        }
    }
    
    var viewModel: SettingsScreenViewModel
    @State private var activeSheet: ActiveSheet?

    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Server Configuration")) {
                    serverDomain
                    maxAgeDuration
                    storeInterval
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            DurationSelectionView(
                title: sheet.title,
                configuration: sheet.configuration,
                selectedDuration: sheet.defaultValue,
                cancelAction: { activeSheet = nil },
                applyAction: { value in
                    switch sheet {
                    case .maxAge:
                        viewModel.userDidSelectMaxAgeDuration(value)
                    case .storeInterval:
                        viewModel.userDidSelectStoreInterval(value)
                    }
                    activeSheet = nil
                }
            )
            .presentationDetents([.height(360)])
            .presentationDragIndicator(.visible)
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.viewDidTriggerOnAppear)
    }
    
    private var serverDomain: some View {
        NavigationLink(destination: ServerDomainView(viewModel: viewModel.makeServerDomainViewModel())) {
            HStack {
                Text("Server Domain: ")
                Spacer()
                Text("\(viewModel.serverDomain)")
            }
            .foregroundStyle(viewModel.serverDomainValid ? Color.primary : Color.red)
        }
    }
    
    private var maxAgeDuration: some View {
        HStack {
            Text("Max Age Duration: ")
            Spacer()
            Button(action: {
                activeSheet = .maxAge(viewModel.maxAgeSeconds)
            }) {
                Text("\(viewModel.maxAge)")
            }
        }
        .foregroundStyle(viewModel.maxAgeValid ? Color.primary : Color.red)
    }
    
    private var storeInterval: some View {
        HStack {
            Text("Store Interval: ")
            Spacer()
            Button(action: {
                activeSheet = .storeInterval(viewModel.storeIntervalSeconds)
            }) {
                Text("\(viewModel.storeInterval)")
            }
        }
        .foregroundStyle(viewModel.storeIntervalValid ? Color.primary : Color.red)
    }
}

#Preview {
    SettingsScreen(viewModel: SettingsScreenViewModel())
}
