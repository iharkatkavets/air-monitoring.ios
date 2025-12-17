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
    private lazy var apiClient: APIClient = APIClientImpl(server: AppSettings.serverDomain)
    @Published var errorMessage: String? = nil
    private lazy var notificationCenter: NotificationCenter = .default

    init() {
    }
    
    func viewDidTriggerOnAppear() {
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
        return ServerDomainViewModel(onDomainUpdate: { [weak self] in
            self?.load()
            self?.notificationCenter.post(name: .domainUpdated, object: nil)
        })
    }
    
    private func load() {
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        serverDomain = AppSettings.serverDomain
        maxAge = DurationParser.parse(AppSettings.maxAge)
        storeInterval = DurationParser.parse(AppSettings.storeInterval)
    }
}

