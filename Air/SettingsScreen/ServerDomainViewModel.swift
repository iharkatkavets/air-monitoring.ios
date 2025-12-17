//
//  ServerDomainViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 11/11/2025.
//

import Combine
import Foundation

@Observable
@MainActor
final class ServerDomainViewModel  {
    var serverDomain: String = AppSettings.serverDomain
    var errorMessage: String?
    var shouldDismiss = false
    private let onDomainUpdate: ()->Void
    
    init(onDomainUpdate: @escaping ()->Void) {
        self.onDomainUpdate = onDomainUpdate
    }
    
    func userDidPressConfirm() {
        Task {
            do {
                let client = APIClientImpl(server: serverDomain)
                for settings in try await client.fetchSettings() {
                    switch settings.key {
                    case ServerSettingKey.maxAge:
                        TimeInterval(settings.value).map{ AppSettings.maxAge = $0 }
                    case ServerSettingKey.storeInterval:
                        TimeInterval(settings.value).map{ AppSettings.storeInterval = $0 }
                    default:
                        continue
                    }
                }
                AppSettings.serverDomain = serverDomain
                onDomainUpdate()
                shouldDismiss = true
            }
            catch {
                if !error.isCancellationError {
                    errorMessage = (error as? APIClientError)?.message
                }
            }
        }
    }
}
