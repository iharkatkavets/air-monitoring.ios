//
//  UserDefaultsValue.swift
//  Air
//
//  Created by Ihar Katkavets on 29/10/2025.
//

import Foundation

@propertyWrapper
public struct UserDefaultsValue<Value: Codable> {
    let key: String
    let storage: UserDefaults
    let defaultValue: Value
    
    public var wrappedValue: Value {
        get {
            if let data = storage.object(forKey: key) as? Data,
               let result = try? JSONDecoder().decode(Value.self, from: data) {
                return result
            }
            else {
                return defaultValue
            }
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                storage.set(encoded, forKey: key)
            }
        }
    }
        
    public init(wrappedValue defaultValue: Value, _ key: String, _ storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }
}

public extension UserDefaultsValue where Value: ExpressibleByNilLiteral {
    init(_ key: String, storage: UserDefaults = .standard) {
        self.init(wrappedValue: nil, key, storage)
    }
}
