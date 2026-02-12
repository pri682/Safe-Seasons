//
//  AskDisasterReadyOrchestrator.swift
//  DisasterReady
//
//  SRP: Q&A orchestration. Uses FM when available (iOS 26+), else rule-based. DIP: preferred + fallback.
//

import Foundation

final class AskDisasterReadyOrchestrator: AskDisasterReadyUseCaseProtocol, @unchecked Sendable {
    private var preferred: AskDisasterReadyUseCaseProtocol?
    private let fallback: AskDisasterReadyUseCaseProtocol

    init(preferred: AskDisasterReadyUseCaseProtocol?, fallback: AskDisasterReadyUseCaseProtocol) {
        self.preferred = preferred
        self.fallback = fallback
    }

    /// Lazily upgrade the preferred implementation after launch.
    func upgradePreferred(_ newPreferred: AskDisasterReadyUseCaseProtocol) {
        self.preferred = newPreferred
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
