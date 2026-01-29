//
//  HomeViewModel.swift
//  SafeSeasons
//
//  SRP: Home tab presentation. DIP: depends on StateRiskUseCaseProtocol, OfflineAIUseCaseProtocol, AskSafeSeasonsUseCaseProtocol.
//

import Foundation
import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let usedAppleIntelligence: Bool
    
    init(content: String, isUser: Bool, usedAppleIntelligence: Bool = false) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.usedAppleIntelligence = usedAppleIntelligence
    }
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var states: [StateRisk] = []
    @Published private(set) var selectedState: StateRisk?
    @Published private(set) var contextualTips: [String] = []
    @Published private(set) var activeAlerts: [WeatherAlert] = []
    @Published private(set) var activeSeasonalRisks: [String] = []
    @Published private(set) var askResponse: String = ""
    @Published private(set) var isAsking: Bool = false
    @Published private(set) var lastUsedAppleIntelligence: Bool = false
    @Published private(set) var askError: String?
    @Published private(set) var chatMessages: [ChatMessage] = []

    private let stateUseCase: StateRiskUseCaseProtocol
    private let offlineAIUseCase: OfflineAIUseCaseProtocol
    private let askUseCase: AskSafeSeasonsUseCaseProtocol
    private let weatherAlertUseCase: WeatherAlertUseCaseProtocol
    private let extendedFeatures: ExtendedFeaturesOrchestrator?
    private let currentMonthProvider: () -> String
    
    // Streaming state
    @Published private(set) var streamingResponse: String = ""
    @Published private(set) var isStreaming: Bool = false

    init(
        stateUseCase: StateRiskUseCaseProtocol,
        offlineAIUseCase: OfflineAIUseCaseProtocol,
        askUseCase: AskSafeSeasonsUseCaseProtocol,
        weatherAlertUseCase: WeatherAlertUseCaseProtocol,
        extendedFeatures: ExtendedFeaturesOrchestrator? = nil,
        currentMonthProvider: @escaping () -> String = { let f = DateFormatter(); f.dateFormat = "MMMM"; return f.string(from: Date()) }
    ) {
        self.stateUseCase = stateUseCase
        self.offlineAIUseCase = offlineAIUseCase
        self.askUseCase = askUseCase
        self.weatherAlertUseCase = weatherAlertUseCase
        self.extendedFeatures = extendedFeatures
        self.currentMonthProvider = currentMonthProvider
    }

    var isAppleIntelligenceAvailable: Bool { askUseCase.isAppleIntelligenceAvailable() }

    func load() {
        states = stateUseCase.getAllStates()
        selectedState = stateUseCase.getCurrentState() ?? stateUseCase.getAllStates().first
        refreshContextualTips()
    }

    func setCurrentState(_ state: StateRisk) {
        stateUseCase.setCurrentState(state)
        selectedState = state
        refreshContextualTips()
    }

    func ask(question: String) {
        let q = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, !isAsking, !isStreaming else { return }

        // Add user message to chat history
        let userMessage = ChatMessage(content: q, isUser: true)
        chatMessages.append(userMessage)

        // Try streaming first if available, else use regular ask
        if extendedFeatures?.askUseCase is StreamingAskUseCaseProtocol {
            streamAsk(question: q)
        } else {
            regularAsk(question: q)
        }
    }
    
    private func regularAsk(question: String) {
        // Prepare state on the main actor
        askError = nil
        askResponse = ""
        isAsking = true
        lastUsedAppleIntelligence = false

        // Capture dependencies and context locally to avoid sending `self` across actors
        let useCase = self.askUseCase
        let state = self.selectedState
        let month = self.currentMonthProvider()
        let aiAvailable = self.isAppleIntelligenceAvailable
        let context = AskContext(state: state, month: month)

        Task {
            do {
                // Perform the async work off the main actor
                let answer = try await useCase.ask(question: question, context: context)
                // Hop back to the main actor to update published properties
                await MainActor.run {
                    // Clean the response to remove null prefixes and repetition
                    let cleanedAnswer = self.cleanResponse(answer)
                    self.askResponse = cleanedAnswer
                    self.lastUsedAppleIntelligence = aiAvailable
                    self.isAsking = false
                    // Add AI response to chat history
                    let aiMessage = ChatMessage(content: cleanedAnswer, isUser: false, usedAppleIntelligence: aiAvailable)
                    self.chatMessages.append(aiMessage)
                }
            } catch {
                await MainActor.run {
                    self.askError = error.localizedDescription
                    self.isAsking = false
                    // Add error message to chat history
                    let errorMessage = ChatMessage(content: "Sorry, I encountered an error: \(error.localizedDescription)", isUser: false)
                    self.chatMessages.append(errorMessage)
                }
            }
        }
    }
    
    func streamAsk(question: String) {
        guard let extended = extendedFeatures?.askUseCase as? StreamingAskUseCaseProtocol else {
            regularAsk(question: question)
            return
        }
        
        askError = nil
        streamingResponse = ""
        isStreaming = true
        lastUsedAppleIntelligence = extendedFeatures?.isAppleIntelligenceAvailable ?? false
        
        let state = self.selectedState
        let month = self.currentMonthProvider()
        let context = AskContext(state: state, month: month)
        let aiAvailable = extendedFeatures?.isAppleIntelligenceAvailable ?? false
        
        Task {
            var fullResponse = ""
            do {
                for try await chunk in extended.streamAsk(question: question, context: context) {
                    await MainActor.run {
                        fullResponse += chunk
                        self.streamingResponse = fullResponse
                    }
                }
                await MainActor.run {
                    self.isStreaming = false
                    // Clean the response to remove null prefixes and repetition
                    let cleanedResponse = self.cleanResponse(fullResponse)
                    // Add complete AI response to chat history
                    let aiMessage = ChatMessage(content: cleanedResponse, isUser: false, usedAppleIntelligence: aiAvailable)
                    self.chatMessages.append(aiMessage)
                    self.streamingResponse = ""
                }
            } catch {
                await MainActor.run {
                    self.isStreaming = false
                    self.askError = error.localizedDescription
                    let errorMessage = ChatMessage(content: "Sorry, I encountered an error: \(error.localizedDescription)", isUser: false)
                    self.chatMessages.append(errorMessage)
                    self.streamingResponse = ""
                }
            }
        }
    }

    func clearAskState() {
        askResponse = ""
        askError = nil
        lastUsedAppleIntelligence = false
    }
    
    func clearChatHistory() {
        chatMessages.removeAll()
        clearAskState()
    }

    private func refreshContextualTips() {
        let month = currentMonthProvider()
        contextualTips = offlineAIUseCase.getContextualTips(state: selectedState, month: month)
        activeAlerts = weatherAlertUseCase.getAlerts(state: selectedState, month: month)
        activeSeasonalRisks = getActiveSeasonalRisks(month: month)
    }
    
    /// Returns active seasonal hazard names for the current month
    private func getActiveSeasonalRisks(month: String) -> [String] {
        guard let state = selectedState else { return [] }
        var risks: Set<String> = []
        for seasonal in state.seasonalRisks {
            if seasonal.months.contains(month) || seasonal.months.contains("All Year") {
                risks.formUnion(seasonal.hazards)
            }
        }
        return Array(risks).sorted()
    }
    
    /// Returns the most severe active alert, or nil if none
    var primaryActiveAlert: WeatherAlert? {
        activeAlerts.sorted { $0.severity.rawValue > $1.severity.rawValue }.first
    }
    
    /// Returns a summary string for active disaster risks
    var activeDisasterSummary: String {
        if let alert = primaryActiveAlert {
            return alert.title
        } else if !activeSeasonalRisks.isEmpty {
            let risks = activeSeasonalRisks.prefix(2).joined(separator: " & ")
            return "\(risks) Risk"
        } else {
            return "No Active Warnings"
        }
    }
    
    /// Returns true if there are any active alerts or seasonal risks
    var hasActiveDisasters: Bool {
        !activeAlerts.isEmpty || !activeSeasonalRisks.isEmpty
    }
    
    // MARK: - Extended Features
    
    /// Generate a structured preparedness plan
    func generatePreparednessPlan(for question: String) async throws -> PreparednessPlan {
        guard let extended = extendedFeatures else {
            throw NSError(domain: "HomeViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Extended features not available"])
        }
        let context = AskContext(state: selectedState, month: currentMonthProvider())
        return try await extended.guidedGeneration.generatePreparednessPlan(for: question, context: context)
    }
    
    /// Classify a question
    func classifyQuestion(_ question: String) async throws -> QuestionClassification {
        guard let extended = extendedFeatures else {
            throw NSError(domain: "HomeViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Extended features not available"])
        }
        return try await extended.contentTagging.classifyQuestion(question)
    }
    
    /// Summarize a disaster
    func summarizeDisaster(_ disaster: Disaster) async throws -> String {
        guard let extended = extendedFeatures else {
            throw NSError(domain: "HomeViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Extended features not available"])
        }
        return try await extended.summarization.summarizeDisaster(disaster)
    }
    
    /// Prioritize emergency actions
    func prioritizeEmergencyActions(disaster: String, context: String) async throws -> PrioritizedActions {
        guard let extended = extendedFeatures else {
            throw NSError(domain: "HomeViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Extended features not available"])
        }
        return try await extended.emergencyPrioritization.prioritizeEmergencyActions(disaster: disaster, context: context)
    }
    
    /// Parse a natural language query
    func parseQuery(_ question: String) async throws -> PreparednessQuery {
        guard let extended = extendedFeatures else {
            throw NSError(domain: "HomeViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Extended features not available"])
        }
        return try await extended.queryParsing.parseQuery(question)
    }
    
    /// Start a conversation session
    func startConversationSession() {
        guard let extended = extendedFeatures else { return }
        let context = AskContext(state: selectedState, month: currentMonthProvider())
        extended.conversationSession.startSession(context: context)
    }
    
    /// Clear conversation session
    func clearConversationSession() {
        extendedFeatures?.conversationSession.clearSession()
    }
    
    // MARK: - Response Cleaning
    
    /// Cleans response content to remove null prefixes, excessive repetition, and other artifacts
    private func cleanResponse(_ content: String) -> String {
        var cleaned = content
        
        // Remove "null" prefix (case insensitive, with various whitespace patterns)
        let nullPatterns = ["null", "null ", "null\n", "null\t"]
        for pattern in nullPatterns {
            if cleaned.lowercased().hasPrefix(pattern.lowercased()) {
                cleaned = String(cleaned.dropFirst(pattern.count)).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                break
            }
        }
        
        // Remove excessive repetition by detecting repeated sentences
        let sentences = cleaned.components(separatedBy: CharacterSet(charactersIn: ".!?\n"))
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 10 } // Filter out very short fragments
        
        var uniqueSentences: [String] = []
        var seenSentences = Set<String>()
        
        for sentence in sentences {
            // Normalize for comparison (lowercase, remove extra spaces)
            let normalized = sentence.lowercased()
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            // Only add if we haven't seen this exact sentence before
            if !normalized.isEmpty && !seenSentences.contains(normalized) {
                seenSentences.insert(normalized)
                uniqueSentences.append(sentence)
            }
        }
        
        // Rejoin sentences with proper punctuation
        if !uniqueSentences.isEmpty {
            cleaned = uniqueSentences.joined(separator: ". ")
            if !cleaned.hasSuffix(".") && !cleaned.hasSuffix("!") && !cleaned.hasSuffix("?") {
                cleaned += "."
            }
        }
        
        return cleaned.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

