//
//  MeasurementsScreen.swift
//  Air
//
//  Created by Ihar Katkavets on 19/10/2025.
//

import SwiftUI

struct MeasurementsScreen: View {
    @ObservedObject var viewModel: MeasurementsScreenViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.measurements) { item in
                MeasurementRow(item: item)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
            }
            .listSectionMargins(.init(), 0)
            .environment(\.defaultMinListHeaderHeight, 0)
            
            if viewModel.canLoadMore {
                loadMoreRow
            }
        }
        .listRowSpacing(12)
        .contentMargins(.top, 0)
        .contentMargins(.horizontal, 12)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.clear)
        .navigationTitle("Measurements")
        .toolbarTitleDisplayMode(.inline)
        .task {
            viewModel.fetchNextPage()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear(perform: viewModel.viewDidTriggerOnAppear)
        .alert("Data Retreiving Error",
               isPresented: .constant(viewModel.errorMessage != nil),
               actions: {
            Button("OK", role: .close) {
                viewModel.errorMessage = nil
            }
            Button("Retry", role: .confirm) {
                viewModel.fetchNextPage()
            }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
    
    private var loadMoreRow: some View {
        HStack {
            Spacer()
            if viewModel.isLoading {
                ProgressView().padding(.vertical, 12)
            } else if viewModel.canLoadMore && viewModel.errorMessage == nil {
                Button(viewModel.loadMoreButtonTitle, role: .confirm, action: {
                    viewModel.fetchNextPage()
                })
                .buttonStyle(.borderedProminent)
                .tint(Color.secondary.opacity(0.12))
            }
            Spacer()
        }
        .listRowInsets(.init())
        .listRowSeparator(.hidden)
        .task {
            viewModel.fetchNextPage()
        }
    }
}

#Preview {
    MeasurementsScreen(viewModel: MeasurementsScreenViewModel())
}
