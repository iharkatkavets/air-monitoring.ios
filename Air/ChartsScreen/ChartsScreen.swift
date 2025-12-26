//
//  ChartsScreen.swift
//  Air
//
//  Created by Ihar Katkavets on 31/10/2025.
//

import SwiftUI
import MarkdownUI
import Collections

struct ChartsScreen: View {
    @State var viewModel: ChartsScreenViewModel
    @State var isNumberConentrationInfoPresented = false
    @State var isMassConcentrationInfoPresented = false
    @State var toobarButtonRect: CGRect = .zero
    @State private var listHeight: CGFloat = 0
    var isAlertPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    var body: some View {
        list()
        .onAppear { viewModel.viewDidTriggerOnAppear() }
        .navigationTitle("Live Charts")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            toolBarPlusButton
        }
        .alert(
            "Data Retreiving Error",
            isPresented: isAlertPresented,
            actions: {
                Button("OK", role: .close) {
                    viewModel.errorMessage = nil
                }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
    
    private func list() -> some View {
        List(viewModel.sections) { s in
            Section {
                ChartsGroupView(
                    spacing: 16,
                    height: heightForGroupOfCharts(s.chartsCount),
                    viewModel: s.viewModel)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } header: {
                listHeader(s.sensorID)
                    .listRowInsets(EdgeInsets(top: 0, leading: 32, bottom: -16, trailing: 32))
            }
        }
        .listSectionSpacing(16)
        .scrollIndicators(.hidden)
        .edgesIgnoringSafeArea(.horizontal)
        .listStyle(.plain)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.size.height, initial: true) { _, newValue in
                        listHeight = newValue
                    }
            }
        )
    }
    
    private func listHeader(_ sensorID: String) -> some View {
        HStack {
            Text(sensorID)
                .foregroundStyle(.white)
        }
    }
    
    private var toolBarPlusButton: some ToolbarContent {
        ToolbarItem {
            Button(action: viewModel.userDidPressAddSensor) {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
            .popover(isPresented: $viewModel.sensorsListPopupIsPresented, attachmentAnchor: .point(.top), arrowEdge: .top) {
                SelectableSensorsListView(viewModel: viewModel.sensorsListPopupViewModel)
                    .presentationCompactAdaptation(.popover)
                    .frame(width: 300, height: 400)
            }
        }
    }
    
    private func heightForGroupOfCharts(_ count: Int) -> CGFloat {
        return CGFloat(count)*listHeight/2
    }
    
    @ViewBuilder
    private func errorViewIfNeeded() -> some View {
        if let errorMessage = viewModel.errorMessage {
            Button(action: viewModel.userDidPressTryAgain) {
                VStack(alignment: .center, spacing: 0) {
                    Text("Error")
                    Text(errorMessage)
                }
            }
        }
    }
}

#Preview {
    ChartsScreen(viewModel: ChartsScreenViewModel())
}
