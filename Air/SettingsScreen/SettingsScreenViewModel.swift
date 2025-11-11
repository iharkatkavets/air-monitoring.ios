//
//  SettingsScreenViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 29/10/2025.
//

import Foundation
import Combine


@MainActor
final class SettingsScreenViewModel: ObservableObject {
    @Published var serverDomain = ""
    @Published var maxAge = ""
    @Published var storeInterval = ""
    private var apiClient: APIClient
    @Published var errorMessage: String? = nil

    init() {
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        load()
    }
    
    func userDidSelectMaxAgeDuration(_ duration: DurationSeconds) {
        Task {
            do {
                try await apiClient.updateSetting(duration, for: .maxAge)
                maxAge = DurationParser.parse(duration)
            } catch {
                errorMessage = (error as? APIClientError)?.message
            }
        }
    }
    
    func userDidSelectStoreInterval(_ interval: DurationSeconds) {
        Task {
            do {
                try await apiClient.updateSetting(interval, for: .storeInterval)
                storeInterval = DurationParser.parse(interval)
            } catch {
                errorMessage = (error as? APIClientError)?.message
            }
        }
    }
    
    func makeServerDomainViewModel() -> ServerDomainViewModel {
        return ServerDomainViewModel(onUpdate: { [weak self] in
            self?.load()
        })
    }
    
    private func load() {
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        serverDomain = AppSettings.serverDomain
        maxAge = DurationParser.parse(AppSettings.maxAge)
        storeInterval = DurationParser.parse(AppSettings.storeInterval)
    }
}

