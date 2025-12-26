//
//  SafeAreaInsets.swift
//  Air
//
//  Created by Ihar Katkavets on 25/12/2025.
//

import SwiftUI

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication
            .shared
            .keyWindow?
            .safeAreaInsets
            .edgeInsets ?? EdgeInsets()
    }
}

private extension UIEdgeInsets {
    var edgeInsets: EdgeInsets {
        .init(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}
