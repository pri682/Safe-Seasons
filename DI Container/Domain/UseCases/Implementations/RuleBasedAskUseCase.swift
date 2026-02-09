//
//  RuleBasedAskUseCase.swift
//  SafeSeasons
//
//  SRP: rule-based Q&A only. Keyword match → disaster content. No FM. DIP: DisasterUseCase, OfflineAIUseCase.
//

import Foundation

final class RuleBasedAskUseCase: AskSafeSeasonsUseCaseProtocol, @unchecked Sendable {
    private let disasterUseCase: DisasterUseCaseProtocol
    private let offlineAIUseCase: OfflineAIUseCaseProtocol
    private let currentMonthProvider: () -> String

    init(
        disasterUseCase: DisasterUseCaseProtocol,
        offlineAIUseCase: OfflineAIUseCaseProtocol,
        currentMonthProvider: @escaping () -> String = { let f = DateFormatter(); f.dateFormat = "MMMM"; return f.string(from: Date()) }
    ) {
        self.disasterUseCase = disasterUseCase
        self.offlineAIUseCase = offlineAIUseCase
        self.currentMonthProvider = currentMonthProvider
    }

    func isAppleIntelligenceAvailable() -> Bool { false }

    func ask(question: String, context: AskContext) async throws -> String {
        let q = question.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else {
            return "Ask something like \"What should I do during a tornado?\" or \"How do I prepare for a hurricane?\" Use the Browse tab for hazard-specific steps."
        }

        let disasters = disasterUseCase.getAllCategories().flatMap { $0.disasters }
        let matched = disasters.first { d in
            q.contains(d.name.lowercased()) || d.name.lowercased().contains(q)
        }
        if let d = matched {
            var out = "\(d.name)\n\n\(d.description)\n\nPreparedness steps:\n"
            out += d.preparednessSteps.map { "• \($0)" }.joined(separator: "\n")
            out += "\n\nSupplies: " + d.supplies.joined(separator: ", ")
            return out
        }

        // Only return state tips when the user explicitly asked about state / this month (not for unrelated questions like "tell me about mouse").
        let asksAboutStateOrMonth = q.contains("state") || q.contains("this month") || q.contains("my state") || q.contains("my area") || (context.state.map { q.contains($0.name.lowercased()) || q.contains($0.abbreviation.lowercased()) } ?? false)
        if asksAboutStateOrMonth, let state = context.state {
            let tips = offlineAIUseCase.getContextualTips(state: state, month: context.month)
            if !tips.isEmpty {
                var out = "This month in \(state.name):\n\n"
                out += tips.map { "• \($0)" }.joined(separator: "\n")
                return out
            }
        }

        return "Use the Browse tab to explore hazards (tornadoes, floods, hurricanes, etc.) and their steps. Select your state on Home for \"This month\" tips. For life-threatening emergencies, call 911."
    }

    private static func defaultMonth() -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f.string(from: Date())
    }
}

