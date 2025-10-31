//
//  SettingsScreen.swift
//  Air
//
//  Created by Ihar Katkavets on 29/10/2025.
//

import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsScreenViewModel
    @FocusState var isFocused: Bool
    
    
    var body: some View {
        Form {
            Section(header: Text("Server Configuration")) {
                TextField("Server Domain, e.g. raspberrypi.local", text: $viewModel.serverDomain)
                    .focused($isFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.none)
                    .keyboardType(.URL)
            }
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .onTapGesture {
            isFocused = false
        }
    }
}

#Preview {
    SettingsScreen(viewModel: SettingsScreenViewModel())
}
