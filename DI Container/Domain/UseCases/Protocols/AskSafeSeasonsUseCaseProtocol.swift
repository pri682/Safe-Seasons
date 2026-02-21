

import Foundation

struct AskContext {
    let state: StateRisk?
    let month: String
}

protocol AskDisasterReadyUseCaseProtocol: Sendable {
    
    func isAppleIntelligenceAvailable() -> Bool

   
    func ask(question: String, context: AskContext) async throws -> String
}


protocol ExtendedAskDisasterReadyUseCaseProtocol: AskDisasterReadyUseCaseProtocol, StreamingAskUseCaseProtocol {
   
}

extension ExtendedAskDisasterReadyUseCaseProtocol {
    func prewarmModel() {}
}
