//
//  Error+Extensions.swift
//  Air
//
//  Created by Ihar Katkavets on 20/10/2025.
//

import Foundation

nonisolated extension Error {
    var isNetworkError: Bool {
        let error = self as NSError
        return error.domain == NSURLErrorDomain
    }
    
    var isTimeoutError: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain
        && nsError.code == NSURLErrorTimedOut
    }
    
    var isCancellationError: Bool {
        return self is CancellationError || (self as NSError).code == NSURLErrorCancelled
    }
    
    var nsErrorCode: Int {
        return (self as NSError).code
    }
}
