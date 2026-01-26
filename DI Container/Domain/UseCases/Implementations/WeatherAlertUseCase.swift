//
//  WeatherAlertUseCase.swift
//  SafeSeasons
//
//  SRP: weather alert orchestration. DIP: depends on WeatherAlertRepositoryProtocol only.
//

import Foundation

final class WeatherAlertUseCase: WeatherAlertUseCaseProtocol {
    private let repository: WeatherAlertRepositoryProtocol

    init(repository: WeatherAlertRepositoryProtocol) {
        self.repository = repository
    }

    func getAlerts(state: StateRisk?, month: String) -> [WeatherAlert] {
        guard let state = state else { return [] }
        return repository.fetchAlerts(stateAbbr: state.abbreviation, month: month)
    }
}
