//
//  AirApp.swift
//  Air
//
//  Created by Ihar Katkavets on 18/10/2025.
//

import SwiftUI

@main
struct AirApp: App {
    @State var rootViewModel = RootViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: rootViewModel)
        }
    }
}

