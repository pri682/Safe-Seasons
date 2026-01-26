//
//  WeatherAlertUseCaseProtocol.swift
//  SafeSeasons
//
//  SRP: weather alert orchestration. DIP: depends on WeatherAlertRepositoryProtocol only.
//

import Foundation

protocol WeatherAlertUseCaseProtocol {
    /// Returns alerts for the given state and month. Offline only (preloaded templates).
    func getAlerts(state: StateRisk?, month: String) -> [WeatherAlert]
}
