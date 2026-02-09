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
// Uses Foundation Models for full on-device text generation (not Core ML tagging/extraction only).
// When Apple Intelligence is available, Ask SafeSeasons answers are generated by the language model.

@available(iOS 26.0, *)
final class FoundationModelsExtendedFeatures: ExtendedAskSafeSeasonsUseCaseProtocol,
                                               GuidedGenerationUseCaseProtocol,
                                               ContentTaggingUseCaseProtocol,
                                               SummarizationUseCaseProtocol,
                                               EmergencyPrioritizationUseCaseProtocol,
                                               QueryParsingUseCaseProtocol,
                                               ConversationSessionProtocol,
                                               @unchecked Sendable {
    
    private var conversationSession: LanguageModelSession?
    private var conversationTranscript: Transcript?
    
    init() {}
    
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
        let session = LanguageModelSession(instructions: instructions)
        
        let options = GenerationOptions(
            sampling: .greedy,
            temperature: 0.4,
            maximumResponseTokens: 400
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
                        continuation.finish(throwing: FoundationModelsError.appleIntelligenceUnavailable)
                        return
                    }
                    
                    let instructions = buildInstructions(context: context)
                    let session = LanguageModelSession(instructions: instructions)
                    
                    let prompt = Prompt { question }
                    // Foundation Model call: on-device language model generates the response (no tools).
                    let stream = session.streamResponse(
                        to: prompt,
                        options: GenerationOptions(sampling: .greedy, temperature: 0.4, maximumResponseTokens: 400)
                    )
                    
                    // Handle cumulative streaming: Foundation Models returns full response so far, not incremental chunks
                    var previousContent = ""
                    
                    for try await partial in stream {
                        let currentContent = partial.content
                        
                        // If current content starts with previous, it's cumulative - extract new part only
                        if currentContent.hasPrefix(previousContent) && currentContent.count > previousContent.count {
                            var newChunk = String(currentContent.dropFirst(previousContent.count))
                            // Strip leading "null" so the UI never shows it (API sometimes sends it as first partial)
                            newChunk = stripLeadingNull(newChunk)
                            if !newChunk.isEmpty {
                                continuation.yield(newChunk)
                                previousContent = currentContent
                            }
                        } else if !currentContent.isEmpty && currentContent != previousContent {
                            var chunk = currentContent
                            chunk = stripLeadingNull(chunk)
                            if !chunk.isEmpty {
                                continuation.yield(chunk)
                                previousContent = currentContent
                            }
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
        
        let instructions = "Generate a structured preparedness plan. Extract disaster type, steps, supplies, and urgency level."
        let session = LanguageModelSession(instructions: instructions)
        
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
        
        let sessionInstructions = "Generate a personalized preparedness checklist. Consider disaster type, location, and user needs."
        let session = LanguageModelSession(instructions: sessionInstructions)
        
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
        
        let session = LanguageModelSession(instructions: "Summarize disaster preparedness information in 2-3 sentences. Focus on key actions.")
        
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
        
        let session = LanguageModelSession(instructions: "Summarize preparedness steps concisely.")
        
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
        
        let session = LanguageModelSession(instructions: "Prioritize emergency actions for disasters. Output structured steps with priority and estimated time.")
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
        
        let session = LanguageModelSession(instructions: "Parse natural language into structured preparedness queries: disaster type, state, month, query type.")
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
        
        let instructions = buildInstructions(context: context)
        conversationSession = LanguageModelSession(instructions: instructions)
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
    
    /// Load the model into memory so the first user request is faster (Code-Along prewarm pattern).
    func prewarmModel() {
        guard isAppleIntelligenceAvailable() else { return }
        Task {
            do {
                let session = LanguageModelSession(instructions: "You are a helpful assistant. Reply with one word.")
                _ = try await session.respond(
                    to: Prompt("Hi"),
                    options: GenerationOptions(sampling: .greedy, maximumResponseTokens: 1)
                )
            } catch {
                // Prewarm is best-effort; ignore errors (e.g. user cancelled, model busy).
            }
        }
    }
    
    // MARK: - Private Helpers
    
    /// Removes a leading "null" (or "null" plus whitespace) so the UI never displays it during streaming.
    private func stripLeadingNull(_ content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        if lower == "null" { return "" }
        if lower.hasPrefix("null") {
            let after = String(trimmed.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
            return after
        }
        return content
    }
    
    private func buildInstructions(context: AskContext) -> String {
        var s = "You are SafeSeasons, a disaster preparedness assistant. Answer every question from your knowledge. No tools—you generate all content.\n\n"
        
        if let state = context.state {
            s += "User's location: \(state.name) (\(state.abbreviation)). Current month: \(context.month). Common hazards: \(state.topHazards.joined(separator: ", ")).\n\n"
        } else {
            s += "User has not selected a state. Current month: \(context.month).\n\n"
        }
        
        s += "Answer the question the user asked. For disaster preparedness (tornadoes, hurricanes, floods, etc.): give a brief definition, then specific steps and tips. For state/region questions (e.g. \"what should I know for Connecticut\", \"this month\"): use your knowledge about that state and season.\n\n"
        s += "FORMATTING: Put a blank line between each tip or section; start each bold heading on its own line with a blank line before it; put a blank line between list items. Do not run sections together on the same line. Never include \"null\". For life-threatening emergencies say to call 911. Write naturally and concisely."
        
        return s
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