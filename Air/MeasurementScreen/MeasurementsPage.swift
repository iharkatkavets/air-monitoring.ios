//
//  MeasurementsPage.swift
//  Air
//
//  Created by Ihar Katkavets on 19/10/2025.
//

typealias NextPageCursor = String

struct MeasurementsPage: Decodable {
    let measurements: [Measurement]
    let hasMore: Bool
    let nextPageCursor: NextPageCursor?
    
    enum CodingKeys: String, CodingKey {
        case measurements = "items"
        case hasMore = "has_more"
        case nextPageCursor = "next_cursor"
    }
}
