//
//  OfflineAIUseCase.swift
//  SafeSeasons
//
//  SRP: contextual tips orchestration. DIP: depends on OfflineAIRuleEngineProtocol only.
//

import Foundation

final class OfflineAIUseCase: OfflineAIUseCaseProtocol {
    private let engine: OfflineAIRuleEngineProtocol

    init(engine: OfflineAIRuleEngineProtocol) {
        self.engine = engine
    }

    func getContextualTips(state: StateRisk?, month: String) -> [String] {
        guard let state = state else { return [] }

        let hazards = deriveHazards(for: state, month: month)
        guard !hazards.isEmpty else { return [] }

        let ids = engine.narrativeIds(stateAbbr: state.abbreviation, month: month, hazards: hazards)
        return ids.map { RiskNarratives.text(for: $0) }
    }

    /// Combines topHazards + seasonal hazards for the given month (or "All Year").
    private func deriveHazards(for state: StateRisk, month: String) -> [String] {
        var set: Set<String> = Set(state.topHazards)

        for seasonal in state.seasonalRisks {
            if seasonal.months.contains(month) || seasonal.months.contains("All Year") {
                for h in seasonal.hazards { set.insert(h) }
            }
        }

        return Array(set)
    }
}
