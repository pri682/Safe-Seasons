//
//  WeatherAlertRepositoryProtocol.swift
//  SafeSeasons
//
//  SRP: weather alert data access. DIP: repositories depend on this protocol.
//

import Foundation

protocol WeatherAlertRepositoryProtocol {
    /// Returns alerts matching state abbreviation and month. Offline only (preloaded templates).
    func fetchAlerts(stateAbbr: String, month: String) -> [WeatherAlert]
}
