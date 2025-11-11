//
//  App+Extensions.swift
//  Air
//
//  Created by Ihar Katkavets on 10/11/2025.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
