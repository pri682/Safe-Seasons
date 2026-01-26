//
//  ExtendedFeaturesOrchestrator.swift
//  SafeSeasons
//
//  SRP: Orchestrates extended Foundation Models features with fallback. DIP: preferred + fallback pattern.
//

import Foundation

/// Orchestrator for extended Foundation Models features
final class ExtendedFeaturesOrchestrator: @unchecked Sendable {
    // Core ask functionality
    let askUseCase: ExtendedAskSafeSeasonsUseCaseProtocol
    
    // Extended features
    let guidedGeneration: GuidedGenerationUseCaseProtocol
    let contentTagging: ContentTaggingUseCaseProtocol
    let summarization: SummarizationUseCaseProtocol
    let emergencyPrioritization: EmergencyPrioritizationUseCaseProtocol
    let queryParsing: QueryParsingUseCaseProtocol
    let conversationSession: ConversationSessionProtocol
    
    init(
        preferredAsk: ExtendedAskSafeSeasonsUseCaseProtocol?,
        fallbackAsk: ExtendedAskSafeSeasonsUseCaseProtocol,
        preferredGuided: GuidedGenerationUseCaseProtocol?,
        fallbackGuided: GuidedGenerationUseCaseProtocol,
        preferredTagging: ContentTaggingUseCaseProtocol?,
        fallbackTagging: ContentTaggingUseCaseProtocol,
        preferredSummarization: SummarizationUseCaseProtocol?,
        fallbackSummarization: SummarizationUseCaseProtocol,
        preferredPrioritization: EmergencyPrioritizationUseCaseProtocol?,
        fallbackPrioritization: EmergencyPrioritizationUseCaseProtocol,
        preferredParsing: QueryParsingUseCaseProtocol?,
        fallbackParsing: QueryParsingUseCaseProtocol,
        preferredConversation: ConversationSessionProtocol?,
        fallbackConversation: ConversationSessionProtocol
    ) {
        // Use preferred if available and Apple Intelligence is available, else fallback
        if #available(iOS 26.0, *), let preferred = preferredAsk, preferred.isAppleIntelligenceAvailable() {
            self.askUseCase = preferred
            self.guidedGeneration = preferredGuided ?? fallbackGuided
            self.contentTagging = preferredTagging ?? fallbackTagging
            self.summarization = preferredSummarization ?? fallbackSummarization
            self.emergencyPrioritization = preferredPrioritization ?? fallbackPrioritization
            self.queryParsing = preferredParsing ?? fallbackParsing
            self.conversationSession = preferredConversation ?? fallbackConversation
        } else {
            self.askUseCase = fallbackAsk
            self.guidedGeneration = fallbackGuided
            self.contentTagging = fallbackTagging
            self.summarization = fallbackSummarization
            self.emergencyPrioritization = fallbackPrioritization
            self.queryParsing = fallbackParsing
            self.conversationSession = fallbackConversation
        }
    }
    
    var isAppleIntelligenceAvailable: Bool {
        askUseCase.isAppleIntelligenceAvailable()
    }
}
