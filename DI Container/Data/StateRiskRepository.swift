//
//  StateRiskRepository.swift
//  SafeSeasons
//
//  SRP: state-risk data access only. DIP: depends on KeyValueStoring.
//

import Foundation

final class StateRiskRepository: StateRiskRepositoryProtocol {
    private let store: KeyValueStoring
    private let states: [StateRisk]

    init(store: KeyValueStoring) {
        self.store = store
        self.states = EmbeddedData.states
    }

    func fetchAll() -> [StateRisk] {
        states
    }

    func fetchCurrent() -> StateRisk? {
        guard let name = store.object(forKey: PersistenceKeys.selectedStateName) as? String else {
            return states.first
        }
        return states.first { $0.name == name } ?? states.first
    }

    func saveCurrent(_ state: StateRisk) {
        store.set(state.name, forKey: PersistenceKeys.selectedStateName)
    }
}
