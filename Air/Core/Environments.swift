//
//  Environments.swift
//  Air
//
//  Created by Ihar Katkavets on 08/12/2025.
//

import SwiftUI

private struct ScreenSizeKey: EnvironmentKey {
    static let defaultValue = UIScreen.main.bounds.size
}

extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}
