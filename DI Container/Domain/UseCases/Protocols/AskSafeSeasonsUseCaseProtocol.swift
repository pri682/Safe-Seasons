

import Foundation

struct AskContext {
    let state: StateRisk?
    let month: String
}

protocol AskSafeSeasonsUseCaseProtocol: Sendable {
    
    func isAppleIntelligenceAvailable() -> Bool

   
    func ask(question: String, context: AskContext) async throws -> String
}


protocol ExtendedAskSafeSeasonsUseCaseProtocol: AskSafeSeasonsUseCaseProtocol, StreamingAskUseCaseProtocol {
   
}

extension ExtendedAskSafeSeasonsUseCaseProtocol {
    func prewarmModel() {}
}
