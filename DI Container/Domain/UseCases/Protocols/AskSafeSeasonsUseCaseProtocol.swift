

import Foundation

/// Context passed when asking a preparedness question (state, month).
struct AskContext {
    let state: StateRisk?
    let month: String
}

protocol AskSafeSeasonsUseCaseProtocol: Sendable {
    /// True when Apple Intelligence / Foundation Models is available and used for answers.
    func isAppleIntelligenceAvailable() -> Bool

    /// Ask a preparedness question. Uses FM when available, else rule-based match.
    func ask(question: String, context: AskContext) async throws -> String
}


protocol ExtendedAskSafeSeasonsUseCaseProtocol: AskSafeSeasonsUseCaseProtocol, StreamingAskUseCaseProtocol {
   
}

extension ExtendedAskSafeSeasonsUseCaseProtocol {
    func prewarmModel() {}
}
