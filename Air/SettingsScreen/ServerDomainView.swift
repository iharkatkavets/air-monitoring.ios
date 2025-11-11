//
//  ServerDomainView.swift
//  Air
//
//  Created by Ihar Katkavets on 11/11/2025.
//

import SwiftUI

struct ServerDomainView: View {
    @State var viewModel: ServerDomainViewModel
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Server Domain, e.g. raspberrypi.local", text: $viewModel.serverDomain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .keyboardType(.URL)
        }
        .toolbar {
            Button(role: .confirm, action: viewModel.userDidPressConfirm)
                .disabled(viewModel.serverDomain.isEmpty)
        }
        .onChange(of: viewModel.shouldDismiss) { _, value in
            if value {
                dismiss()
            }
        }
    }
}
