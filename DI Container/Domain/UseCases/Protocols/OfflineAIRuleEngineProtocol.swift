//
//  OfflineAIRuleEngineProtocol.swift
//  SafeSeasons
//
//  SRP: rule-based (state, month, hazard) → narrative IDs. DIP: engine depends on rules data.
//

import Foundation

protocol OfflineAIRuleEngineProtocol {
    /// Evaluates rules for (stateAbbr, month, hazards). Returns deduplicated narrative IDs in order.
    func narrativeIds(stateAbbr: String, month: String, hazards: [String]) -> [RiskNarrativeId]
}
