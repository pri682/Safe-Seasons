//
//  KeyValueStoring.swift
//  SafeSeasons
//
//  SRP: persistence only. DIP: depend on this protocol, not UserDefaults.
//

import Foundation

protocol KeyValueStoring: AnyObject {
    func object(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
    func removeObject(forKey key: String)
}
