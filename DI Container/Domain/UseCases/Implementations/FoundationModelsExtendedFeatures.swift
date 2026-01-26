//
//  FoundationModelsExtendedFeatures.swift
//  SafeSeasons
//
//  SRP: Extended Foundation Models features implementation. DIP: implements all FM feature protocols.
//  Compiles only when FoundationModels SDK is available (e.g. Xcode 26 / iOS 26).
//

#if canImport(FoundationModels)

import Foundation
import FoundationModels

// MARK: - @Generable Types (Foundation Models only)

// These are @Generable versions of the types for Foundation Models
// They convert to/from the regular types defined in FoundationModelsFeaturesProtocol.swift

@available(iOS 26.0, *)
@Generable
private struct GenerablePreparednessPlan: Equatable {
    let disasterType: String
    let steps: [String]
    let supplies: [String]
    let urgencyLevel: String
}

@available(iOS 26.0, *)
@Generable
private struct GenerablePersonalizedChecklistItem: Equatable {
    let name: String
    let priority: String
    let reason: String
}

@available(iOS 26.0, *)
@Generable
private struct GenerablePersonalizedChecklist: Equatable {
    let items: [GenerablePersonalizedChecklistItem]
}

@available(iOS 26.0, *)
@Generable
private struct GenerableQuestionClassification: Equatable {
    let disasterType: String?
    let mentionedState: String?
    let urgency: String
}

@available(iOS 26.0, *)
@Generable
private struct GenerableQuestionRoute: Equatable {
    let category: String
    let confidence: Double
    let suggestedData: String?
}

@available(iOS 26.0, *)
@Generable
private struct GenerablePrioritizedAction: Equatable {
    let step: String
    let priority: String
    let estimatedTime: String?
}

@available(iOS 26.0, *)
@Generable
private struct GenerablePrioritizedActions: Equatable {
    let actions: [GenerablePrioritizedAction]
}

@available(iOS 26.0, *)
@Generable
private struct GenerablePreparednessQuery: Equatable {
    let disasterType: String?
    let state: String?
    let month: String?
    let queryType: String
}

@available(iOS 26.0, *)
@Generable
private struct GenerableUserQueryExtraction: Equatable {
    let mentionedState: String?
    let mentionedDisaster: String?
    let timeReference: String?
    let questionType: String
}

// MARK: - Conversion Helpers

@available(iOS 26.0, *)
private extension PreparednessPlan {
    init(from generable: GenerablePreparednessPlan) {
        self.init(
            disasterType: generable.disasterType,
            steps: generable.steps,
            supplies: generable.supplies,
            urgencyLevel: generable.urgencyLevel
        )
    }
}

@available(iOS 26.0, *)
private extension PersonalizedChecklistItem {
    init(from generable: GenerablePersonalizedChecklistItem) {
        self.init(
            name: generable.name,
            priority: generable.priority,
            reason: generable.reason
        )
    }
}

@available(iOS 26.0, *)
private extension PersonalizedChecklist {
    init(from generable: GenerablePersonalizedChecklist) {
        self.init(
            items: generable.items.map { PersonalizedChecklistItem(from: $0) }
        )
    }
}

@available(iOS 26.0, *)
private extension QuestionClassification {
    init(from generable: GenerableQuestionClassification) {
        self.init(
            disasterType: generable.disasterType,
            mentionedState: generable.mentionedState,
            urgency: generable.urgency
        )
    }
}

@available(iOS 26.0, *)
private extension QuestionRoute {
    init(from generable: GenerableQuestionRoute) {
        self.init(
            category: generable.category,
            confidence: generable.confidence,
            suggestedData: generable.suggestedData
        )
    }
}

@available(iOS 26.0, *)
private extension PrioritizedAction {
    init(from generable: GenerablePrioritizedAction) {
        self.init(
            step: generable.step,
            priority: generable.priority,
            estimatedTime: generable.estimatedTime
        )
    }
}

@available(iOS 26.0, *)
private extension PrioritizedActions {
    init(from generable: GenerablePrioritizedActions) {
        self.init(
            actions: generable.actions.map { PrioritizedAction(from: $0) }
        )
    }
}

@available(iOS 26.0, *)
private extension PreparednessQuery {
    init(from generable: GenerablePreparednessQuery) {
        self.init(
            disasterType: generable.disasterType,
            state: generable.state,
            month: generable.month,
            queryType: generable.queryType
        )
    }
}

@available(iOS 26.0, *)
private extension UserQueryExtraction {
    init(from generable: GenerableUserQueryExtraction) {
        self.init(
            mentionedState: generable.mentionedState,
            mentionedDisaster: generable.mentionedDisaster,
            timeReference: generable.timeReference,
            questionType: generable.questionType
        )
    }
}

// MARK: - Foundation Models Extended Features Implementation

@available(iOS 26.0, *)
final class FoundationModelsExtendedFeatures: ExtendedAskSafeSeasonsUseCaseProtocol,
                                               GuidedGenerationUseCaseProtocol,
                                               ContentTaggingUseCaseProtocol,
                                               SummarizationUseCaseProtocol,
                                               EmergencyPrioritizationUseCaseProtocol,
                                               QueryParsingUseCaseProtocol,
                                               ConversationSessionProtocol,
                                               @unchecked Sendable {
    
    private let offlineAIUseCase: OfflineAIUseCaseProtocol
    private var conversationSession: LanguageModelSession?
    private var conversationTranscript: Transcript?
    
    init(offlineAIUseCase: OfflineAIUseCaseProtocol) {
        self.offlineAIUseCase = offlineAIUseCase
    }
    
    // MARK: - AskSafeSeasonsUseCaseProtocol
    
    func isAppleIntelligenceAvailable() -> Bool {
        switch SystemLanguageModel.default.availability {
        case .available: return true
        case .unavailable: return false
        @unknown default: return false
        }
    }
    
    func ask(question: String, context: AskContext) async throws -> String {
        guard isAppleIntelligenceAvailable() else {
            throw FoundationModelsError.appleIntelligenceUnavailable
        }
        
        let instructions = buildInstructions(context: context)
        let model = SystemLanguageModel.default
        let session = LanguageModelSession(
            model: model,
            tools: [GetContextualTipsTool(offlineAIUseCase: offlineAIUseCase)],
            instructions: { instructions }
        )
        
        let options = GenerationOptions(
            sampling: .greedy,
            temperature: 0.6,
            maximumResponseTokens: 512
        )
        let response = try await session.respond(to: question, options: options)
        return response.content
    }
    
    // MARK: - StreamingAskUseCaseProtocol
    
    func streamAsk(question: String, context: AskContext) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard isAppleIntelligenceAvailable() else {
                        throw FoundationModelsError.appleIntelligenceUnavailable
                    }
                    
                    let instructions = buildInstructions(context: context)
                    let model = SystemLanguageModel.default
                    let session = LanguageModelSession(
                        model: model,
                        tools: [GetContextualTipsTool(offlineAIUseCase: offlineAIUseCase)],
                        instructions: { instructions }
                    )
                    
                    let stream = try await session.streamResponse(
                        options: GenerationOptions(temperature: 0.6, maximumResponseTokens: 512)
                    ) {
                        question
                    }
                    
                    var fullText = ""
                    for try await partial in stream {
                        let newChunk = partial.content
                        if !newChunk.isEmpty {
                            fullText += newChunk
                            continuation.yield(newChunk)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - GuidedGenerationUseCaseProtocol
    
    func generatePreparednessPlan(for question: String, context: AskContext) async throws -> PreparednessPlan {
        guard isAppleIntelligenceAvailable() else {
            throw FoundationModelsError.appleIntelligenceUnavailable
        }
        
        let session = LanguageModelSession(
            model: .default,
            instructions: {
                "Generate a structured preparedness plan. Extract disaster type, steps, supplies, and urgency level."
            }
        )
        
        let result = try await session.respond(
            to: Prompt(question),
            generating: GenerablePreparednessPlan.self,
            options: GenerationOptions(temperature: 0.5)
        )
        
        return PreparednessPlan(from: result.content)
    }
    
    func generatePersonalizedChecklist(disaster: String, state: String, userProfile: String) async throws -> PersonalizedChecklist {
        guard isAppleIntelligenceAvailable() else {
            throw FoundationModelsError.appleIntelligenceUnavailable
        }
        
        let session = LanguageModelSession(
            model: .default,
            instructions: {
                "Generate a personalized preparedness checklist. Consider disaster type, location, and user needs."
            }
        )
        
        let prompt = """
        Disaster: \(disaster)
        Location: \(state)
        User profile: \(userProfile)
        
        Generate a personalized checklist with 5-10 items, each with priority (critical/high/medium/low) and reason.
        """
        
        let result = try await session.respond(
            to: Prompt(prompt),
            generating: GenerablePersonalizedChecklist.self,
            options: GenerationOptions(temperature: 0.6)
        )
        
        return PersonalizedChecklist(from: result.content)
    }
    
    // MARK: - ContentTaggingUseCaseProtocol
    
    func classifyQuestion(_ question: String) async throws -> QuestionClassification {
        let taggingModel = SystemLanguageModel(useCase: .contentTagging)
        guard taggingModel.availability == .available else {
            throw FoundationModelsError.appleIntelligenceUnavailable
        }
        
        let session = LanguageModelSession(model: taggingModel)
        let result = try await session.respond(
            to: Prompt("Classify this preparedness question: \(question)"),
            generating: GenerableQuestionClassification.self,
            options: GenerationOptions(temperature: 0.3)
        )
        
        return QuestionClassification(from: result.content)
    }
    
    func routeQuestion(_ question: String) async throws -> QuestionRoute {
        let taggingModel = SystemLanguageModel(useCase: .contentTagging)
        guard taggingModel.availability == .available else {
            throw FoundationModelsError.appleIntelligenceUnavailable
        }
        
        let session = LanguageModelSession(model: taggingModel)
        let result = try await session.respond(
            to: Prompt("Route this question to the right category (disaster/state/supplies/evacuation/general): \(question)"),
            generating: GenerableQuestionRoute.self,
            options: GenerationOptions(temperature: 0.2)
        )
        
        return QuestionRoute(from: result.content)
    }
    
    func extractQueryInfo(_ question: String) async throws -> UserQueryExtraction {
        let taggingModel = SystemLanguageModel(useCase: .contentTagging)
        guard taggingModel.availability == .available else {
            throw FoundationModelsError.appleIntelligenceUnavailable
        }
        
        let session = LanguageModelSession(model: taggingModel)
        let result = try await session.respond(
            to: Prompt("Extract information from: \(question)"),
            generating: GenerableUserQueryExtraction.self,
            options: GenerationOptions(temperature: 0.3)
        )
        
        return UserQueryExtraction(from: result.content)
    }
    
    // MARK: - SummarizationUseCaseProtocol
    
    func summarizeDisaster(_ disaster: Disaster) async throws -> String {
        guard isAppleIntelligenceAvailable() else {
            throw FoundationModelsError.appleIntelligenceUnavailable
        }
        
        let session = LanguageModelSession(
            model: .default,
            instructions: {
                "Summarize disaster preparedness information in 2-3 sentences. Focus on key actions."
            }
        )
        
        let prompt = """
        Disaster: \(disaster.name)
        Description: \(disaster.description)
        Steps: \(disaster.preparednessSteps.joined(separator: ", "))
        
        Provide a brief summary.
        """
        
        let response = try await session.respond(
            to: prompt,
            options: GenerationOptions(temperature: 0.4, maximumResponseTokens: 150)
        )
        
        return response.content
    }
    
    func summarizePreparednessSteps(_ steps: [String]) async throws -> String {
        guard isAppleIntelligenceAvailable() else {
            throw FoundationModelsError.appleIntelligenceUnavailable
        }
        
        let session = LanguageModelSession(
            model: .default,
            instructions: {
                "Summarize preparedness steps concisely."
            }
        )
        
        let prompt = "Steps: \(steps.joined(separator: ", "))\n\nProvide a brief summary."
        let response = try await session.respond(
            to: prompt,
            options: GenerationOptions(temperature: 0.4, maximumResponseTokens: 100)
        )
        
        return response.content
    }
    
    // MARK: - EmergencyPrioritizationUseCaseProtocol
    
    func prioritizeEmergencyActions(disaster: String, context: String) async throws -> PrioritizedActions {
        guard isAppleIntelligenceAvailable() else {
            throw FoundationModelsError.appleIntelligenceUnavailable
        }
        
        let session = LanguageModelSession(model: .default)
        let result = try await session.respond(
            to: Prompt("Prioritize emergency actions for: \(disaster). Context: \(context)"),
            generating: GenerablePrioritizedActions.self,
            options: GenerationOptions(temperature: 0.5)
        )
        
        return PrioritizedActions(from: result.content)
    }
    
    // MARK: - QueryParsingUseCaseProtocol
    
    func parseQuery(_ question: String) async throws -> PreparednessQuery {
        guard isAppleIntelligenceAvailable() else {
            throw FoundationModelsError.appleIntelligenceUnavailable
        }
        
        let session = LanguageModelSession(model: .default)
        let result = try await session.respond(
            to: Prompt("Parse this into a structured query: \(question)"),
            generating: GenerablePreparednessQuery.self,
            options: GenerationOptions(temperature: 0.3)
        )
        
        return PreparednessQuery(from: result.content)
    }
    
    // MARK: - ConversationSessionProtocol
    
    func startSession(context: AskContext) {
        guard isAppleIntelligenceAvailable() else { return }
        
        let model = SystemLanguageModel.default
        let instructions = buildInstructions(context: context)
        
        // Create session - transcript is restored via session's internal state, not as a parameter
        conversationSession = LanguageModelSession(
            model: model,
            tools: [GetContextualTipsTool(offlineAIUseCase: offlineAIUseCase)],
            instructions: { instructions }
        )
    }
    
    func ask(_ question: String) async throws -> String {
        guard let session = conversationSession else {
            throw FoundationModelsError.noActiveSession
        }
        
        let response = try await session.respond(to: question)
        // Update transcript from response entries if available
        if !response.transcriptEntries.isEmpty {
            conversationTranscript = Transcript(entries: response.transcriptEntries)
        }
        return response.content
    }
    
    func clearSession() {
        conversationSession = nil
        conversationTranscript = nil
    }
    
    var hasActiveSession: Bool {
        conversationSession != nil
    }
    
    // MARK: - Private Helpers
    
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

// MARK: - Tool Implementation

@available(iOS 26.0, *)
private final class GetContextualTipsTool: Tool, @unchecked Sendable {
    let name = "getContextualTips"
    let description = "Gets contextual preparedness tips for a specific state and month."
    
    @Generable
    struct Arguments {
        let stateAbbr: String
        let month: String
    }
    
    private let offlineAIUseCase: OfflineAIUseCaseProtocol
    
    init(offlineAIUseCase: OfflineAIUseCaseProtocol) {
        self.offlineAIUseCase = offlineAIUseCase
    }
    
    func call(arguments: Arguments) async throws -> [String] {
        let state = EmbeddedData.states.first { $0.abbreviation == arguments.stateAbbr }
        let tips = offlineAIUseCase.getContextualTips(state: state, month: arguments.month)
        let text = tips.isEmpty
            ? "No specific tips for this state and month. Suggest general preparedness: water, food, first aid, documents, evacuation plan."
            : tips.joined(separator: "\n")
        return [text]
    }
}

// MARK: - Errors

enum FoundationModelsError: LocalizedError {
    case appleIntelligenceUnavailable
    case noActiveSession
    
    var errorDescription: String? {
        switch self {
        case .appleIntelligenceUnavailable:
            return "Apple Intelligence is not available on this device."
        case .noActiveSession:
            return "No active conversation session."
        }
    }
}

#endif