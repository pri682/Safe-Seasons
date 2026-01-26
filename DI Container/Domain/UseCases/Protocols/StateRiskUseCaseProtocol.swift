//
//  StateRiskUseCaseProtocol.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//


import Foundation

protocol StateRiskUseCaseProtocol {
    func getAllStates() -> [StateRisk]
    func getStateByName(_ name: String) -> StateRisk?
    func getCurrentState() -> StateRisk?
    func setCurrentState(_ state: StateRisk)
}