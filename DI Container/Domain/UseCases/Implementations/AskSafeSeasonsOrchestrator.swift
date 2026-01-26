//
//  AskSafeSeasonsOrchestrator.swift
//  SafeSeasons
//
//  SRP: Q&A orchestration. Uses FM when available (iOS 26+), else rule-based. DIP: preferred + fallback.
//

import Foundation

final class AskSafeSeasonsOrchestrator: AskSafeSeasonsUseCaseProtocol {
    private let preferred: AskSafeSeasonsUseCaseProtocol?
    private let fallback: AskSafeSeasonsUseCaseProtocol

    init(preferred: AskSafeSeasonsUseCaseProtocol?, fallback: AskSafeSeasonsUseCaseProtocol) {
        self.preferred = preferred
        self.fallback = fallback
    }

    func isAppleIntelligenceAvailable() -> Bool {
        guard #available(iOS 26.0, *), let preferred = preferred else { return false }
        return preferred.isAppleIntelligenceAvailable()
    }

    func ask(question: String, context: AskContext) async throws -> String {
        if #available(iOS 26.0, *), let preferred = preferred, preferred.isAppleIntelligenceAvailable() {
            return try await preferred.ask(question: question, context: context)
        }
        return try await fallback.ask(question: question, context: context)
    }
}
