//
//  RuleBasedExtendedFeatures.swift
//  SafeSeasons
//
//  SRP: Rule-based fallback implementations for all extended features. DIP: implements feature protocols.
//  Provides offline, deterministic fallbacks when Foundation Models are unavailable.
//

import Foundation

/// Rule-based fallback for extended Foundation Models features.
/// Uses @unchecked Sendable so streamAsk’s Task closure can capture self under Swift 6.
final class RuleBasedExtendedFeatures: ExtendedAskSafeSeasonsUseCaseProtocol,
                                        GuidedGenerationUseCaseProtocol,
                                        ContentTaggingUseCaseProtocol,
                                        SummarizationUseCaseProtocol,
                                        EmergencyPrioritizationUseCaseProtocol,
                                        QueryParsingUseCaseProtocol,
                                        ConversationSessionProtocol,
                                        @unchecked Sendable {
    
    private let disasterUseCase: DisasterUseCaseProtocol
    private let offlineAIUseCase: OfflineAIUseCaseProtocol
    private var conversationHistory: [String] = []
    
    init(disasterUseCase: DisasterUseCaseProtocol, offlineAIUseCase: OfflineAIUseCaseProtocol) {
        self.disasterUseCase = disasterUseCase
        self.offlineAIUseCase = offlineAIUseCase
    }
    
    // MARK: - AskSafeSeasonsUseCaseProtocol
    
    func isAppleIntelligenceAvailable() -> Bool {
        false // Rule-based, not Apple Intelligence
    }
    
    func ask(question: String, context: AskContext) async throws -> String {
        // Use existing rule-based logic
        let lowerQuestion = question.lowercased()
        
        // Check for disaster mentions
        for category in disasterUseCase.getAllCategories() {
            for disaster in category.disasters {
                if lowerQuestion.contains(disaster.name.lowercased()) {
                    return "For \(disaster.name), key steps: \(disaster.preparednessSteps.prefix(3).joined(separator: ", ")). Always call 911 in emergencies."
                }
            }
        }
        
        // Check for state/location mentions
        if let state = context.state, lowerQuestion.contains(state.name.lowercased()) || lowerQuestion.contains(state.abbreviation.lowercased()) {
            let tips = offlineAIUseCase.getContextualTips(state: state, month: context.month)
            if !tips.isEmpty {
                return tips.prefix(2).joined(separator: " ")
            }
        }
        
        // Generic response
        return "I can help with disaster preparedness. Try asking about specific disasters, your state, or preparedness steps. For emergencies, call 911."
    }
    
    // MARK: - StreamingAskUseCaseProtocol
    
    func streamAsk(question: String, context: AskContext) -> AsyncThrowingStream<String, Error> {
        let q = question
        let ctx = context
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let answer = try await self.ask(question: q, context: ctx)
                    let words = answer.components(separatedBy: " ")
                    for (index, word) in words.enumerated() {
                        try await Task.sleep(nanoseconds: 50_000_000)
                        continuation.yield(index == 0 ? word : " \(word)")
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
        let lowerQuestion = question.lowercased()
        var disasterType = "General"
        var steps: [String] = []
        var supplies: [String] = []
        
        // Find matching disaster
        for category in disasterUseCase.getAllCategories() {
            for disaster in category.disasters {
                if lowerQuestion.contains(disaster.name.lowercased()) {
                    disasterType = disaster.name
                    steps = Array(disaster.preparednessSteps.prefix(5))
                    supplies = Array(disaster.supplies.prefix(5))
                    break
                }
            }
        }
        
        if steps.isEmpty {
            steps = ["Create emergency kit", "Develop evacuation plan", "Stay informed", "Secure property", "Know evacuation routes"]
            supplies = ["Water", "Non-perishable food", "First aid kit", "Flashlight", "Batteries"]
        }
        
        let urgency = steps.isEmpty ? "Moderate" : "High"
        return PreparednessPlan(disasterType: disasterType, steps: steps, supplies: supplies, urgencyLevel: urgency)
    }
    
    func generatePersonalizedChecklist(disaster: String, state: String, userProfile: String) async throws -> PersonalizedChecklist {
        var items: [PersonalizedChecklistItem] = []
        
        // Base items
        items.append(PersonalizedChecklistItem(name: "Water (1 gallon per person per day)", priority: "critical", reason: "Essential for survival"))
        items.append(PersonalizedChecklistItem(name: "Non-perishable food (3-day supply)", priority: "critical", reason: "Sustains you during emergencies"))
        items.append(PersonalizedChecklistItem(name: "First aid kit", priority: "high", reason: "Treat injuries immediately"))
        items.append(PersonalizedChecklistItem(name: "Flashlight and batteries", priority: "high", reason: "Light during power outages"))
        items.append(PersonalizedChecklistItem(name: "Important documents", priority: "high", reason: "Identity and insurance proof"))
        
        // Profile-specific items
        if userProfile.lowercased().contains("pet") {
            items.append(PersonalizedChecklistItem(name: "Pet food and supplies", priority: "high", reason: "Care for your pets"))
        }
        if userProfile.lowercased().contains("medical") || userProfile.lowercased().contains("elderly") {
            items.append(PersonalizedChecklistItem(name: "Prescription medications (7-day supply)", priority: "critical", reason: "Maintain health"))
        }
        
        return PersonalizedChecklist(items: items)
    }
    
    // MARK: - ContentTaggingUseCaseProtocol
    
    func classifyQuestion(_ question: String) async throws -> QuestionClassification {
        let lowerQuestion = question.lowercased()
        
        // Extract disaster type
        var disasterType: String? = nil
        let disasterKeywords: [String: String] = [
            "tornado": "tornado",
            "hurricane": "hurricane",
            "flood": "flood",
            "wildfire": "wildfire",
            "earthquake": "earthquake",
            "blizzard": "blizzard",
            "snow": "blizzard"
        ]
        
        for (keyword, type) in disasterKeywords {
            if lowerQuestion.contains(keyword) {
                disasterType = type
                break
            }
        }
        
        // Extract state
        var mentionedState: String? = nil
        for state in EmbeddedData.states {
            if lowerQuestion.contains(state.name.lowercased()) || lowerQuestion.contains(state.abbreviation.lowercased()) {
                mentionedState = state.name
                break
            }
        }
        
        // Determine urgency
        let urgency: String
        if lowerQuestion.contains("emergency") || lowerQuestion.contains("urgent") || lowerQuestion.contains("now") {
            urgency = "emergency"
        } else if lowerQuestion.contains("soon") || lowerQuestion.contains("prepare") {
            urgency = "high"
        } else if lowerQuestion.contains("plan") || lowerQuestion.contains("future") {
            urgency = "moderate"
        } else {
            urgency = "low"
        }
        
        return QuestionClassification(disasterType: disasterType, mentionedState: mentionedState, urgency: urgency)
    }
    
    func routeQuestion(_ question: String) async throws -> QuestionRoute {
        let lowerQuestion = question.lowercased()
        
        let category: String
        let suggestedData: String?
        
        if lowerQuestion.contains("supply") || lowerQuestion.contains("kit") || lowerQuestion.contains("item") {
            category = "supplies"
            suggestedData = nil
        } else if lowerQuestion.contains("evacuat") || lowerQuestion.contains("leave") || lowerQuestion.contains("go") {
            category = "evacuation"
            suggestedData = nil
        } else if lowerQuestion.contains("state") || lowerQuestion.contains("location") || lowerQuestion.contains("where") {
            category = "state"
            suggestedData = extractStateFromQuestion(question)
        } else if containsDisasterName(question) != nil {
            category = "disaster"
            suggestedData = containsDisasterName(question)
        } else {
            category = "general"
            suggestedData = nil
        }
        
        return QuestionRoute(category: category, confidence: 0.7, suggestedData: suggestedData)
    }
    
    func extractQueryInfo(_ question: String) async throws -> UserQueryExtraction {
        let lowerQuestion = question.lowercased()
        
        var mentionedState: String? = nil
        for state in EmbeddedData.states {
            if lowerQuestion.contains(state.name.lowercased()) || lowerQuestion.contains(state.abbreviation.lowercased()) {
                mentionedState = state.name
                break
            }
        }
        
        var mentionedDisaster: String? = nil
        for category in disasterUseCase.getAllCategories() {
            for disaster in category.disasters {
                if lowerQuestion.contains(disaster.name.lowercased()) {
                    mentionedDisaster = disaster.name
                    break
                }
            }
        }
        
        var timeReference: String? = nil
        if lowerQuestion.contains("this month") || lowerQuestion.contains("current") {
            timeReference = "this month"
        } else if lowerQuestion.contains("next week") {
            timeReference = "next week"
        }
        
        let questionType: String
        if lowerQuestion.hasPrefix("how") || lowerQuestion.contains("how to") {
            questionType = "how-to"
        } else if lowerQuestion.hasPrefix("what") {
            questionType = "what-is"
        } else if lowerQuestion.hasPrefix("when") {
            questionType = "when"
        } else if lowerQuestion.hasPrefix("where") {
            questionType = "where"
        } else {
            questionType = "general"
        }
        
        return UserQueryExtraction(mentionedState: mentionedState, mentionedDisaster: mentionedDisaster, timeReference: timeReference, questionType: questionType)
    }
    
    // MARK: - SummarizationUseCaseProtocol
    
    func summarizeDisaster(_ disaster: Disaster) async throws -> String {
        let stepsSummary = disaster.preparednessSteps.prefix(3).joined(separator: ", ")
        return "\(disaster.name): \(disaster.description.prefix(100)). Key steps: \(stepsSummary)."
    }
    
    func summarizePreparednessSteps(_ steps: [String]) async throws -> String {
        if steps.isEmpty {
            return "No steps provided."
        }
        let summary = steps.prefix(3).joined(separator: ", ")
        return "Key steps: \(summary)."
    }
    
    // MARK: - EmergencyPrioritizationUseCaseProtocol
    
    func prioritizeEmergencyActions(disaster: String, context: String) async throws -> PrioritizedActions {
        var actions: [PrioritizedAction] = []
        
        // Find disaster
        var foundDisaster: Disaster? = nil
        for category in disasterUseCase.getAllCategories() {
            if let disaster = category.disasters.first(where: { $0.name.lowercased() == disaster.lowercased() }) {
                foundDisaster = disaster
                break
            }
        }
        
        if let disaster = foundDisaster {
            actions.append(PrioritizedAction(step: "Call 911 if immediate danger", priority: "immediate", estimatedTime: "1 minute"))
            actions.append(PrioritizedAction(step: "Evacuate if ordered", priority: "immediate", estimatedTime: "5 minutes"))
            actions.append(PrioritizedAction(step: "Grab emergency kit", priority: "urgent", estimatedTime: "2 minutes"))
            
            for (index, step) in disaster.preparednessSteps.prefix(3).enumerated() {
                actions.append(PrioritizedAction(step: step, priority: index < 2 ? "important" : "preparatory", estimatedTime: nil))
            }
        } else {
            // Generic prioritization
            actions = [
                PrioritizedAction(step: "Call 911 in emergencies", priority: "immediate", estimatedTime: "1 minute"),
                PrioritizedAction(step: "Evacuate if ordered", priority: "immediate", estimatedTime: "5 minutes"),
                PrioritizedAction(step: "Grab emergency kit", priority: "urgent", estimatedTime: "2 minutes"),
                PrioritizedAction(step: "Stay informed", priority: "important", estimatedTime: nil),
                PrioritizedAction(step: "Follow official guidance", priority: "important", estimatedTime: nil)
            ]
        }
        
        return PrioritizedActions(actions: actions)
    }
    
    // MARK: - QueryParsingUseCaseProtocol
    
    func parseQuery(_ question: String) async throws -> PreparednessQuery {
        let lowerQuestion = question.lowercased()
        
        var disasterType: String? = nil
        for category in disasterUseCase.getAllCategories() {
            for disaster in category.disasters {
                if lowerQuestion.contains(disaster.name.lowercased()) {
                    disasterType = disaster.name
                    break
                }
            }
        }
        
        var state: String? = nil
        for stateRisk in EmbeddedData.states {
            if lowerQuestion.contains(stateRisk.name.lowercased()) || lowerQuestion.contains(stateRisk.abbreviation.lowercased()) {
                state = stateRisk.name
                break
            }
        }
        
        var month: String? = nil
        let months = ["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"]
        for monthName in months {
            if lowerQuestion.contains(monthName) {
                month = monthName.capitalized
                break
            }
        }
        
        let queryType: String
        if lowerQuestion.contains("tip") || lowerQuestion.contains("advice") {
            queryType = "tips"
        } else if lowerQuestion.contains("supply") || lowerQuestion.contains("kit") {
            queryType = "supplies"
        } else if lowerQuestion.contains("step") || lowerQuestion.contains("do") {
            queryType = "steps"
        } else if lowerQuestion.contains("risk") || lowerQuestion.contains("danger") {
            queryType = "risks"
        } else {
            queryType = "tips"
        }
        
        return PreparednessQuery(disasterType: disasterType, state: state, month: month, queryType: queryType)
    }
    
    // MARK: - ConversationSessionProtocol
    
    func startSession(context: AskContext) {
        conversationHistory = []
    }
    
    func ask(_ question: String) async throws -> String {
        conversationHistory.append(question)
        let context = AskContext(state: nil, month: "")
        return try await self.ask(question: question, context: context)
    }
    
    func clearSession() {
        conversationHistory.removeAll()
    }
    
    var hasActiveSession: Bool {
        !conversationHistory.isEmpty
    }
    
    // MARK: - Private Helpers
    
    private func extractStateFromQuestion(_ question: String) -> String? {
        let lowerQuestion = question.lowercased()
        for state in EmbeddedData.states {
            if lowerQuestion.contains(state.name.lowercased()) || lowerQuestion.contains(state.abbreviation.lowercased()) {
                return state.name
            }
        }
        return nil
    }
    
    private func containsDisasterName(_ question: String) -> String? {
        let lowerQuestion = question.lowercased()
        for category in disasterUseCase.getAllCategories() {
            for disaster in category.disasters {
                if lowerQuestion.contains(disaster.name.lowercased()) {
                    return disaster.name
                }
            }
        }
        return nil
    }
}
