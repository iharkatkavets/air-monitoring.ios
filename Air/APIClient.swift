//
//  APIClient.swift
//  Air
//
//  Created by Ihar Katkavets on 19/10/2025.
//

import Foundation

typealias ServerDomain = String

enum APIClientError: Swift.Error {
    case network(String)
    case server(String)
    
    var message: String {
        switch self {
        case .network(let string):
            return string
        case .server(let string):
            return string
        }
    }
}

protocol APIClient: Sendable {
    var server: ServerDomain { get }
    func fetchMeasurementsPage(_ cursor: NextPageCursor?) async throws(APIClientError) -> MeasurementsPage
}

final class APIClientImpl: APIClient {
    private let session: URLSession
    let server: ServerDomain
    
    init(server: ServerDomain) {
        self.server = server
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
    }
    
    func fetchMeasurementsPage(_ cursor: NextPageCursor?) async throws(APIClientError) -> MeasurementsPage {
        do {
            let url = URL(string: "http://\(server)/api/measurements")!
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let cursor {
                urlComponents?.queryItems = [URLQueryItem(name: "cursor", value: cursor)]
            }
            let request = URLRequest(url: urlComponents!.url!)
            let (data, _) = try await session.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let page = try decoder.decode(MeasurementsPage.self, from: data)
            return page
        } catch {
            if error.isNetworkError {
                throw .network("Network error. Check your internet connection")
            } else {
                throw .server("Server error. Try again later")
            }
        }
    }
}
