//
//  TimerStream.swift
//  Air
//
//  Created by Ihar Katkavets on 26/12/2025.
//

import Foundation

nonisolated func periodicStream(
    interval: TimeInterval
) -> AsyncStream<Void> {
    AsyncStream { continuation in
        let task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                continuation.yield(())
            }
            continuation.finish()
        }
        
        continuation.onTermination = { _ in
            task.cancel()
        }
    }
}
