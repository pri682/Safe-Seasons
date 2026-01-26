//
//  OfflineAIUseCaseProtocol.swift
//  SafeSeasons
//
//  SRP: contextual tips orchestration. DIP: depends on OfflineAIRuleEngineProtocol only.
//

import Foundation

protocol OfflineAIUseCaseProtocol {
    /// Returns prewritten risk narratives + tips for (state, month). Empty if no state or no rules match.
    func getContextualTips(state: StateRisk?, month: String) -> [String]
}
