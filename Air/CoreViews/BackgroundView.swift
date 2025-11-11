//
//  BackgroundView.swift
//  Air
//
//  Created by Ihar Katkavets on 10/11/2025.
//

import SwiftUI

struct BackgroundView<Content: View>: View {
    let color: Color
    let contentView: Content
    
    var body: some View {
//        color.
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BackgroundView(color: .black, contentView: Text("Hello"))
}
