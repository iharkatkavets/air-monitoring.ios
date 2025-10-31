//
//  Error+Extensions.swift
//  Air
//
//  Created by Ihar Katkavets on 20/10/2025.
//

import Foundation

extension Error {
    var isNetworkError: Bool {
        let error = self as NSError
        return error.domain == NSURLErrorDomain
    }
}
