//
//  APIClient.swift
//  Air
//
//  Created by Ihar Katkavets on 19/10/2025.
//

import Foundation

typealias ServerDomain = String
typealias SensorID = String
typealias SensorName = String
typealias Measurement = String

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
    func fetchMeasurementsPage(_ sensorID: SensorID, _ cursor: NextPageCursor?) async throws(APIClientError) -> MeasurementsPage
    func fetchSensorStream(_ sensorID: SensorID) async throws(APIClientError) -> AsyncThrowingStream<[MeasurementSSE], any Error>
    func updateSetting(_ value: CustomStringConvertible, for key: ServerSettingKey) async throws(APIClientError)
    func fetchSensors() async throws(APIClientError) -> [Sensor]
}

final class APIClientImpl: APIClient {
    private let session: URLSession
    let server: ServerDomain
    let delegateQueue = OperationQueue()

    init(server: ServerDomain) {
        self.server = server
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        delegateQueue.name = "com.apiclient.network"
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: delegateQueue)
    }
    
    private func urlByAppending(_ path: String) -> URL {
        return URL(string: "http://\(server)/" + path)!
    }
    
    func fetchMeasurementsPage(_ sensorID: SensorID, _ cursor: NextPageCursor?) async throws(APIClientError) -> MeasurementsPage {
        do {
            let url = URL(string: "http://\(server)/api/measurements/\(sensorID)")!
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
    
    func fetchSensorStream(_ sensorID: SensorID) async throws(APIClientError) -> AsyncThrowingStream<[MeasurementSSE], any Error> {
        struct Event: Decodable {
            let items: [MeasurementSSE]
        }
        do {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = .infinity
            config.timeoutIntervalForResource = .infinity
            let session = URLSession(configuration: config)
            let url = URL(string: "http://\(server)/api/measurements/\(sensorID)/stream")!
            let request = URLRequest(url: url)
            let (bytes, _) = try await session.bytes(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        for try await line in bytes.lines where line.hasPrefix("data: "){
                            let jsonStr = line.dropFirst(5)
                            let dataValue = try decoder.decode(Event.self, from: jsonStr.data(using: .utf8)!)
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
            let request = URLRequest(url: urlByAppending("api/settings"))
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
    
    func fetchSensors() async throws(APIClientError) -> [Sensor] {
        struct SensorResponse: Decodable {
            let sensorId: String
            let sensorName: String
            let lastSeen: Date
            let measurements: [Measurement]
            
            enum CodingKeys: String, CodingKey {
                case sensorId = "sensor_id"
                case sensorName = "sensor_name"
                case lastSeen = "last_seen_time"
                case measurements
            }
        }
        
        do {
            let request = URLRequest(url: urlByAppending("api/sensors/"))
            let (data, _) = try await session.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode([SensorResponse].self, from: data)
            return response.map { .init(sensorId: $0.sensorId, sensorName: $0.sensorName, lastSeenTime: $0.lastSeen, measurements: $0.measurements) }
        } catch {
            if error.isNetworkError {
                throw .network("Network error. Check your internet connection")
            } else {
                throw .server("Server error. Try again later")
            }
        }
    }
}
