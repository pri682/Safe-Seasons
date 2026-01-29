//
//  FoundationModelsAskUseCase.swift
//  SafeSeasons
//
//  SRP: Q&A via Apple Foundation Models when available. DIP: depends on OfflineAIUseCaseProtocol.
//  Compiles only when FoundationModels SDK is available (e.g. Xcode 26 / iOS 26).
//

#if canImport(FoundationModels)

import Foundation
import FoundationModels

@available(iOS 26.0, *)
final class FoundationModelsAskUseCase: AskSafeSeasonsUseCaseProtocol, @unchecked Sendable {
    private let offlineAIUseCase: OfflineAIUseCaseProtocol
    private var session: LanguageModelSession?
    private let tool: GetContextualTipsTool

    init(offlineAIUseCase: OfflineAIUseCaseProtocol) {
        self.offlineAIUseCase = offlineAIUseCase
        self.tool = GetContextualTipsTool(offlineAIUseCase: offlineAIUseCase)
    }

    func isAppleIntelligenceAvailable() -> Bool {
        switch SystemLanguageModel.default.availability {
        case .available: return true
        case .unavailable: return false
        @unknown default: return false
        }
    }

    func ask(question: String, context: AskContext) async throws -> String {
        guard isAppleIntelligenceAvailable() else {
            throw AskError.appleIntelligenceUnavailable
        }

        let instructions = buildInstructions(context: context)
        let model = SystemLanguageModel.default
        let session = LanguageModelSession(
            model: model,
            instructions: { instructions }
        )
        self.session = session

        let options = GenerationOptions(
            sampling: .greedy,
            temperature: 0.6,
            maximumResponseTokens: 512
        )
        let response = try await session.respond(to: question, options: options)
        return response.content
    }

    private func buildInstructions(context: AskContext) -> String {
        var s = "You are SafeSeasons, a disaster preparedness assistant. Answer briefly and focus on safety. Use the getContextualTips tool when the user asks about their location, state, or \"this month\" risks."
        if let state = context.state {
            s += " User's state: \(state.name) (\(state.abbreviation)). Current month: \(context.month). Top hazards: \(state.topHazards.joined(separator: ", "))."
        } else {
            s += " User has not selected a state. Current month: \(context.month)."
        }
        s += " Do not make up specific procedures—prefer tool data and general preparedness advice. For life-threatening emergencies, always say to call 911."
        return s
    }
}

enum AskError: Error {
    case appleIntelligenceUnavailable
}

// MARK: - Tool Replacement

@available(iOS 26.0, *)
private final class GetContextualTipsTool {
    private let offlineAIUseCase: OfflineAIUseCaseProtocol

    init(offlineAIUseCase: OfflineAIUseCaseProtocol) {
        self.offlineAIUseCase = offlineAIUseCase
    }

    func call(stateAbbr: String, month: String) async -> String {
        let state = EmbeddedData.states.first { $0.abbreviation == stateAbbr }
        let tips = offlineAIUseCase.getContextualTips(state: state, month: month)
        let text = tips.isEmpty
            ? "No specific tips for this state and month. Suggest general preparedness: water, food, first aid, documents, evacuation plan."
            : tips.joined(separator: "\n")
        return text
    }
}

#endif
