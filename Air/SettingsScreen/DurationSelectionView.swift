//
//  MaxAgeDuration.swift
//  Air
//
//  Created by Ihar Katkavets on 10/11/2025.
//

import SwiftUI

struct DurationSelectionView: View {
    let title: String
    var configuration = DurationPicker.Configuration(numbers: 1...60, units: ["s","m","h","d"])
    @State var selectedDuration: DurationSeconds
    let cancelAction: ()->Void
    let applyAction: (DurationSeconds)->Void
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    var body: some View {
        VStack {
            HStack {
                Button(role: .cancel, action: cancelAction)
                Spacer()
                Text(title).font(.headline)
                Spacer()
                Button(role: .confirm, action: { applyAction(selectedDuration)} )
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            Spacer()
            DurationPicker(duration: $selectedDuration, configuration: configuration)
            Spacer(minLength: safeAreaInsets.bottom+16)
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var isPresented: Bool = false
    
    ZStack(alignment: .top) {
        Color.black
            .ignoresSafeArea(.all)
        Button("Present") {
            isPresented.toggle()
        }
    }
    .sheet(isPresented: $isPresented, content: {
        DurationSelectionView(
            title: "Title",
            selectedDuration: 3,
            cancelAction: {},
            applyAction: { _ in}
        )
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    })
}
