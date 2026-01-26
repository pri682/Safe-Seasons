//
//  StateRiskRepositoryProtocol.swift
//  SafeSeasons
//
//  DIP: use cases depend on this, not concrete StateRiskRepository.
//

import Foundation

protocol StateRiskRepositoryProtocol: AnyObject {
    func fetchAll() -> [StateRisk]
    func fetchCurrent() -> StateRisk?
    func saveCurrent(_ state: StateRisk)
}
