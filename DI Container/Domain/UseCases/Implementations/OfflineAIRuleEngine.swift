//
//  OfflineAIRuleEngine.swift
//  SafeSeasons
//
//  SRP: rule matching only. Uses OfflineAIRules table; no network, no external AI.
//

import Foundation

final class OfflineAIRuleEngine: OfflineAIRuleEngineProtocol {
    func narrativeIds(stateAbbr: String, month: String, hazards: [String]) -> [RiskNarrativeId] {
        var ordered: [RiskNarrativeId] = []
        var seen: Set<RiskNarrativeId> = []

        for hazard in hazards {
            let matches = OfflineAIRules.table.filter { entry in
                entry.stateAbbr == stateAbbr
                    && (entry.month == month || entry.month == "All Year")
                    && entry.hazard == hazard
            }
            for entry in matches {
                for id in entry.narrativeIds where !seen.contains(id) {
                    seen.insert(id)
                    ordered.append(id)
                }
            }
        }

        return ordered
    }
}
