//
//  DurationString.swift
//  Air
//
//  Created by Ihar Katkavets on 10/11/2025.
//

import Foundation

typealias DurationString = String // "1s or 2m or 3h or 4d"

struct DurationParser {
    static func parse(_ string: DurationString) -> DurationSeconds? {
        let pattern = #"(?:(\d+)d)?(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?"#
        guard let match = try? NSRegularExpression(pattern: pattern)
            .firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) else {
            return nil
        }
        
        func value(_ index: Int) -> Double {
            if let r = Range(match.range(at: index), in: string) {
                return Double(string[r]) ?? 0
            }
            return 0
        }
        
        let days = value(1)
        let hours = value(2)
        let minutes = value(3)
        let seconds = value(4)
        return days*86400 + hours*3600 + minutes*60 + seconds
    }
    
    static func parse(_ seconds: DurationSeconds) -> DurationString {
        let seconds = Int(seconds)
        let d = seconds/86400
        let h = (seconds%86400)/3600
        let m = (seconds%3600)/60
        let s = seconds%60
        
        var parts: [String] = []
        if d > 0 { parts.append("\(d)d") }
        if h > 0 { parts.append("\(h)h") }
        if m > 0 { parts.append("\(m)m") }
        if s > 0 || parts.isEmpty { parts.append("\(s)s") }
        
        return parts.joined()
    }
}
