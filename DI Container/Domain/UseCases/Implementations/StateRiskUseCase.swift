//
//  StateRiskUseCase.swift
//  SafeSeasons
//
//  SRP: state selection orchestration. DIP: depends on StateRiskRepositoryProtocol only.
//

import Foundation

final class StateRiskUseCase: StateRiskUseCaseProtocol {
    private let repository: StateRiskRepositoryProtocol

    init(repository: StateRiskRepositoryProtocol) {
        self.repository = repository
    }

    func getAllStates() -> [StateRisk] {
        repository.fetchAll()
    }

    func getStateByName(_ name: String) -> StateRisk? {
        repository.fetchAll().first { $0.name == name }
    }

    func getCurrentState() -> StateRisk? {
        repository.fetchCurrent()
    }

    func setCurrentState(_ state: StateRisk) {
        repository.saveCurrent(state)
    }
}
