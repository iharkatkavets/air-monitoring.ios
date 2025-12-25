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

    var body: some View {
        List(viewModel.sensors, id: \.0) { t in
            Section {
                ChartsGroupView(
                    spacing: 32,
                    height: listHeight/2,
                    viewModel: t.3)
                .frame(height: CGFloat(t.2)*listHeight/2)
                .padding(.top, 16)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } header: {
               Text(t.1)
                    .foregroundStyle(.white)
            }
        }
        .scrollIndicators(.hidden)
        .listSectionSpacing(32)
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
        .onAppear { viewModel.viewDidTriggerOnAppear() }
        .navigationTitle("Live Charts")
        .toolbarTitleDisplayMode(.inline)
        .toolbar(content: {
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
        })
        .alert("Data Retreiving Error",
               isPresented: .constant(viewModel.errorMessage != nil),
               actions: {
            Button("OK", role: .close) {
                viewModel.errorMessage = nil
            }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
    
    
    private func infoView(_ fileName: String) -> some View {
        ScrollView {
            Markdown(MarkdownContent(try! String(contentsOfFile: Bundle.main.path(forResource: fileName, ofType: nil)!, encoding: .utf8)))
                .padding()
        }
    }
    
    private func heightForGroupOfCharts(_ count: Int) -> (CGFloat, Axis) -> CGFloat {
        let count = CGFloat(count)
        return { length, axis in
            count * (length-32) * 0.5
        }
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
