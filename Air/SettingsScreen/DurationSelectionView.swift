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
    let cancelAction: ()->Void
    let applyAction: (DurationSeconds)->Void
    @State var selectedDuration: DurationSeconds = 0
    
   var body: some View {
       VStack {
           HStack {
               Button(role: .cancel, action: cancelAction)
               Spacer()
               Text(title).font(.headline)
               Spacer()
               Button(role: .confirm, action: { applyAction(selectedDuration)} )
           }
           Spacer()
           DurationPicker(duration: $selectedDuration, configuration: configuration)
           Spacer()
       }
       .padding()
    }
}

#Preview {
    DurationSelectionView(title: "Title", cancelAction: {}, applyAction: { _ in})
}
