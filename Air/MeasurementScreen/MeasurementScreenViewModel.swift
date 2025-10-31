//
//  MeasurementScreenViewModel.swift
//  Air
//
//  Created by Ihar Katkavets on 19/10/2025.
//

import Combine
import SwiftUI

@MainActor
final class MeasurementsScreenViewModel: ObservableObject {
    @Published var measurements: [Measurement] = []
    private var nextPageCursor: NextPageCursor?
    var canLoadMore: Bool = true
    var isLoading = false
    private var apiClient: APIClient
    @Published var errorMessage: String? = nil
    var loadMoreButtonTitle: String = "Load more"
    var loadingTask: Task<Void, Never>?
    
    init() {
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
    }
    
    func viewDidTriggerOnAppear() {
        if apiClient.server != AppSettings.serverDomain {
            Task { await refresh() }
        }
    }
    
    func fetchNextPage() {
        loadingTask = Task { [unowned self] in
            do {
                guard !isLoading else {
                    return
                }
                defer {
                    isLoading = false
                }
                try Task.checkCancellation()
                errorMessage = nil
                isLoading = true
                let page = try await apiClient.fetchMeasurementsPage(nextPageCursor)
                try Task.checkCancellation()
                measurements.append(contentsOf: page.measurements)
                canLoadMore = page.hasMore
                nextPageCursor = page.nextPageCursor
                updateLoadMoreButtonTitle()
            }
            catch is CancellationError { }
            catch {
                updateLoadMoreButtonTitle()
                errorMessage = (error as? APIClientError)?.message
            }
        }
    }
    
    private func updateLoadMoreButtonTitle() {
        loadMoreButtonTitle = measurements.isEmpty ? "Fetch Measurements" : "Load more"
    }
    
    func refresh() async {
        errorMessage = nil
        loadingTask?.cancel()
        await loadingTask?.value
        apiClient = APIClientImpl(server: AppSettings.serverDomain)
        measurements.removeAll()
        canLoadMore = true
        nextPageCursor = nil
        fetchNextPage()
    }
}
