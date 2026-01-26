//
//  UserDefaultsKeyValueStore.swift
//  SafeSeasons
//
//  SRP: UserDefaults-backed key-value store. Single responsibility.
//

import Foundation

final class UserDefaultsKeyValueStore: KeyValueStoring {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func object(forKey key: String) -> Any? {
        defaults.object(forKey: key)
    }

    func set(_ value: Any?, forKey key: String) {
        if let value = value {
            defaults.set(value, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }

    func removeObject(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}
