//
//  APIClient.swift
//  Air
//
//  Created by Ihar Katkavets on 19/10/2025.
//

import Foundation

typealias ServerDomain = String

fileprivate struct SettingsResponse: Decodable {
    struct Item: Decodable {
        let key: String
        let value: String
    }
    let settings: [Item]
}

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
    func fetchMeasurementStream() async throws(APIClientError) -> AsyncThrowingStream<[MeasurementSSE], any Error>
    func updateSetting(_ value: CustomStringConvertible, for key: ServerSettingKey) async throws(APIClientError)
}

final class APIClientImpl: APIClient {
    private let session: URLSession
    let server: ServerDomain
    
    init(server: ServerDomain) {
        self.server = server
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: configuration)
    }
    
    private func urlByAppending(_ path: String) -> URL {
        return URL(string: "http://\(server)/" + path)!
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
    
    func fetchMeasurementStream() async throws(APIClientError) -> AsyncThrowingStream<[MeasurementSSE], any Error> {
        struct DataValue: Decodable {
            let items: [MeasurementSSE]
        }
        do {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = .infinity
            config.timeoutIntervalForResource = .infinity
            let session = URLSession(configuration: config)
            let url = URL(string: "http://\(server)/api/measurements/stream")!
            let request = URLRequest(url: url)
            let (bytes, _) = try await session.bytes(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        for try await line in bytes.lines where line.hasPrefix("data: "){
                            let jsonStr = line.dropFirst(5)
                            let dataValue = try decoder.decode(DataValue.self, from: jsonStr.data(using: .utf8)!)
                            continuation.yield(with: .success(dataValue.items))
                        }
                    } catch {
                        continuation.yield(with: .failure(APIClientError.server("Server error. Try again later")))
                    }
                }
            }
        } catch {
            if error.isNetworkError {
                throw .network("Network error. Check your internet connection")
            } else {
                throw .server("Server error. Try again later")
            }
        }
    }
    
    func updateSetting(_ value: CustomStringConvertible, for key: ServerSettingKey) async throws(APIClientError) {
        do {
            var request = URLRequest(url: urlByAppending("api/settings/\(key)"))
            request.httpMethod = "POST"
            request.httpBody = "{\"value\": \"\(value)\"}".data(using: .utf8)
            let (data, _) = try await session.data(for: request)
            _ = try JSONDecoder().decode(SettingsResponse.Item.self, from: data)
        } catch {
            if error.isNetworkError {
                throw .network("Network error. Check your internet connection")
            } else {
                throw .server("Server error. Try again later")
            }
        }
    }
    
    func fetchSettings() async throws(APIClientError) -> [ServerSetting] {
        do {
            let request = URLRequest(url: urlByAppending("api/settings/"))
            let (data, _) = try await session.data(for: request)
            let response = try JSONDecoder().decode(SettingsResponse.self, from: data)
            return response.settings.map { .init(key: $0.key, value: $0.value) }
        } catch {
            if error.isNetworkError {
                throw .network("Network error. Check your internet connection")
            } else {
                throw .server("Server error. Try again later")
            }
        }
    }
}
