# Additional Foundation Models Capabilities for SafeSeasons

This document outlines **additional capabilities** beyond the current "Ask SafeSeasons" Q&A feature that we can implement using Apple Foundation Models.

**Current Implementation:**
- ✅ Basic Q&A (`SystemLanguageModel.default`)
- ✅ Tool calling (`GetContextualTipsTool`)
- ✅ Context-aware instructions

**Additional Capabilities Available:**

---

## 1. **Streaming Responses** (Real-time Text Generation)

**What it does:** Streams text as it's generated, providing a more responsive UX.

**Use case for SafeSeasons:**
- Show preparedness tips appearing word-by-word
- Real-time disaster explanations
- Progressive answer display in chat

**Implementation:**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
func streamPreparednessAnswer(question: String, context: AskContext) async throws -> AsyncThrowingStream<String, Error> {
    guard SystemLanguageModel.default.availability == .available else {
        throw AskError.appleIntelligenceUnavailable
    }
    
    let session = LanguageModelSession(
        model: .default,
        instructions: { buildInstructions(context: context) }
    )
    
    let stream = try await session.streamResponse(
        options: GenerationOptions(temperature: 0.6, maximumResponseTokens: 512)
    ) {
        question
    }
    
    return AsyncThrowingStream { continuation in
        Task {
            for try await partial in stream {
                continuation.yield(partial.content)
            }
            continuation.finish()
        }
    }
}
#endif
```

**UI Integration:**
```swift
// In HomeView or AskSafeSeasonsSheet
Task {
    for try await chunk in viewModel.streamAsk(question: questionText) {
        streamingResponse += chunk
    }
}
```

---

## 2. **Guided Generation** (Structured Output)

**What it does:** Returns structured Swift types instead of plain text.

**Use case for SafeSeasons:**
- Extract disaster type from user questions
- Generate structured preparedness checklists
- Parse location/state from natural language

**Example: Structured Preparedness Plan**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct PreparednessPlan: Equatable {
    let disasterType: String
    @Guide(description: "3-5 key preparedness steps")
    let steps: [String]
    @Guide(description: "Essential supplies needed")
    let supplies: [String]
    let urgencyLevel: String // "Low", "Moderate", "High", "Critical"
}

@available(iOS 26.0, *)
func generatePreparednessPlan(for question: String, context: AskContext) async throws -> PreparednessPlan {
    let session = LanguageModelSession(
        model: .default,
        instructions: {
            "Generate a structured preparedness plan based on the user's question. Extract disaster type, steps, and supplies."
        }
    )
    
    let result = try await session.respond(
        to: Prompt(question),
        generating: PreparednessPlan.self,
        options: GenerationOptions(temperature: 0.5)
    )
    
    return result.content
}
#endif
```

**Benefits:**
- Type-safe data extraction
- Easy to display in UI (lists, cards)
- No manual parsing of text responses

---

## 3. **Content Tagging Model** (Classification & Extraction)

**What it does:** Specialized model for tagging, entity extraction, and classification.

**Use case for SafeSeasons:**
- Classify user questions (e.g., "tornado", "hurricane", "general")
- Extract location mentions from questions
- Tag disaster types in user input

**Implementation:**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct QuestionClassification: Equatable {
    @Guide(.anyOf(["tornado", "hurricane", "flood", "wildfire", "earthquake", "general", "supplies", "evacuation"]))
    let disasterType: String?
    let mentionedState: String?
    let urgency: String // "low", "moderate", "high", "emergency"
}

@available(iOS 26.0, *)
func classifyQuestion(_ question: String) async throws -> QuestionClassification {
    let taggingModel = SystemLanguageModel(useCase: .contentTagging)
    guard taggingModel.availability == .available else {
        throw AskError.appleIntelligenceUnavailable
    }
    
    let session = LanguageModelSession(model: taggingModel)
    let result = try await session.respond(
        to: Prompt("Classify this preparedness question: \(question)"),
        generating: QuestionClassification.self,
        options: GenerationOptions(temperature: 0.3) // Lower temp for classification
    )
    
    return result.content
}
#endif
```

**Use Cases:**
- Route questions to appropriate disaster category
- Show relevant tips based on classification
- Prioritize emergency questions

---

## 4. **Multi-turn Conversations** (Stateful Sessions)

**What it does:** Maintains conversation context across multiple exchanges.

**Use case for SafeSeasons:**
- Follow-up questions ("Tell me more about that")
- Context-aware responses ("What about for my state?")
- Conversation history in chat UI

**Implementation:**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
class ConversationSession {
    private var session: LanguageModelSession?
    private var transcript: Transcript?
    
    func startSession(context: AskContext) {
        let model = SystemLanguageModel.default
        guard model.availability == .available else { return }
        
        session = LanguageModelSession(
            model: model,
            instructions: { buildInstructions(context: context) },
            transcript: transcript // Restore previous conversation
        )
    }
    
    func ask(_ question: String) async throws -> String {
        guard let session = session else {
            throw AskError.appleIntelligenceUnavailable
        }
        
        let response = try await session.respond(to: question)
        transcript = response.transcript // Save for next turn
        return response.content
    }
}
#endif
```

**Benefits:**
- Natural follow-up questions
- Contextual responses
- Better user experience

---

## 5. **Summarization** (Condense Information)

**What it does:** Generate concise summaries of disaster information.

**Use case for SafeSeasons:**
- Summarize long disaster descriptions
- Create quick-reference cards
- Condense preparedness steps

**Implementation:**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
func summarizeDisaster(_ disaster: Disaster) async throws -> String {
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
#endif
```

---

## 6. **Structured Data Extraction** (Parse User Input)

**What it does:** Extract structured information from natural language.

**Use case for SafeSeasons:**
- Extract state name from "I live in Texas"
- Parse disaster type from "What about tornadoes?"
- Extract time references ("this month", "next week")

**Example:**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct UserQueryExtraction: Equatable {
    let mentionedState: String?
    let mentionedDisaster: String?
    let timeReference: String? // "this month", "next week", etc.
    let questionType: String // "how-to", "what-is", "when", "where"
}

@available(iOS 26.0, *)
func extractQueryInfo(_ question: String) async throws -> UserQueryExtraction {
    let session = LanguageModelSession(model: .default)
    let result = try await session.respond(
        to: Prompt("Extract information from: \(question)"),
        generating: UserQueryExtraction.self,
        options: GenerationOptions(temperature: 0.3)
    )
    return result.content
}
#endif
```

---

## 7. **Smart Checklist Generation** (Personalized Plans)

**What it does:** Generate personalized preparedness checklists based on user profile.

**Use case for SafeSeasons:**
- Create custom checklists for specific disasters
- Adapt to user's location and season
- Include user-specific needs (pets, medical conditions)

**Implementation:**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct PersonalizedChecklist: Equatable {
    @Guide(.count(5...10))
    let items: [ChecklistItem]
    
    struct ChecklistItem: Generable, Equatable {
        let name: String
        @Guide(.anyOf(["critical", "high", "medium", "low"]))
        let priority: String
        let reason: String // Why this item is important
    }
}

@available(iOS 26.0, *)
func generatePersonalizedChecklist(
    disaster: String,
    state: String,
    userProfile: String // e.g., "has pets", "elderly", "medical conditions"
) async throws -> PersonalizedChecklist {
    let session = LanguageModelSession(
        model: .default,
        instructions: {
            "Generate a personalized preparedness checklist. Consider the disaster type, location, and user needs."
        }
    )
    
    let prompt = """
    Disaster: \(disaster)
    Location: \(state)
    User profile: \(userProfile)
    
    Generate a personalized checklist.
    """
    
    let result = try await session.respond(
        to: Prompt(prompt),
        generating: PersonalizedChecklist.self,
        options: GenerationOptions(temperature: 0.6)
    )
    
    return result.content
}
#endif
```

---

## 8. **Question Routing** (Smart Categorization)

**What it does:** Route questions to appropriate handlers or data sources.

**Use case for SafeSeasons:**
- Route to disaster-specific info
- Route to state-specific tips
- Route to general preparedness

**Implementation:**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct QuestionRoute: Equatable {
    @Guide(.anyOf(["disaster", "state", "supplies", "evacuation", "general"]))
    let category: String
    let confidence: Double
    let suggestedData: String? // Which disaster/state to look up
}

@available(iOS 26.0, *)
func routeQuestion(_ question: String) async throws -> QuestionRoute {
    let taggingModel = SystemLanguageModel(useCase: .contentTagging)
    let session = LanguageModelSession(model: taggingModel)
    
    let result = try await session.respond(
        to: Prompt("Route this question to the right category: \(question)"),
        generating: QuestionRoute.self,
        options: GenerationOptions(temperature: 0.2) // Low temp for routing
    )
    
    return result.content
}
#endif
```

---

## 9. **Emergency Response Prioritization**

**What it does:** Prioritize actions during emergencies.

**Use case for SafeSeasons:**
- Rank preparedness steps by urgency
- Prioritize evacuation actions
- Order supplies by importance

**Example:**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct PrioritizedActions: Equatable {
    @Guide(.count(3...7))
    let actions: [Action]
    
    struct Action: Generable, Equatable {
        let step: String
        @Guide(.anyOf(["immediate", "urgent", "important", "preparatory"]))
        let priority: String
        let estimatedTime: String? // e.g., "5 minutes"
    }
}

@available(iOS 26.0, *)
func prioritizeEmergencyActions(disaster: String, context: String) async throws -> PrioritizedActions {
    let session = LanguageModelSession(model: .default)
    let result = try await session.respond(
        to: Prompt("Prioritize emergency actions for: \(disaster). Context: \(context)"),
        generating: PrioritizedActions.self
    )
    return result.content
}
#endif
```

---

## 10. **Natural Language to Structured Query**

**What it does:** Convert natural language questions into structured queries.

**Use case for SafeSeasons:**
- "Show me tornado tips for Texas" → Query disaster data
- "What's the risk in Colorado this month?" → Query state/seasonal data
- "Tell me about hurricanes" → Query disaster category

**Implementation:**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct PreparednessQuery: Equatable {
    let disasterType: String?
    let state: String?
    let month: String?
    let queryType: String // "tips", "supplies", "steps", "risks"
}

@available(iOS 26.0, *)
func parseQuery(_ question: String) async throws -> PreparednessQuery {
    let session = LanguageModelSession(model: .default)
    let result = try await session.respond(
        to: Prompt("Parse this into a structured query: \(question)"),
        generating: PreparednessQuery.self,
        options: GenerationOptions(temperature: 0.3)
    )
    return result.content
}
#endif
```

---

## Implementation Priority for SafeSeasons

### **High Priority (Most Useful):**

1. **Streaming Responses** ⭐⭐⭐
   - Better UX for "Ask SafeSeasons"
   - Real-time feedback
   - Easy to implement

2. **Guided Generation for Structured Output** ⭐⭐⭐
   - Extract disaster types, states from questions
   - Generate structured checklists
   - Type-safe data

3. **Content Tagging for Question Classification** ⭐⭐
   - Route questions to right data sources
   - Improve answer relevance
   - Better user experience

### **Medium Priority:**

4. **Multi-turn Conversations** ⭐⭐
   - Follow-up questions
   - Better chat experience
   - Requires session management

5. **Summarization** ⭐
   - Quick-reference cards
   - Condense long descriptions
   - Nice-to-have enhancement

### **Lower Priority (Advanced):**

6. **Personalized Checklist Generation**
7. **Question Routing**
8. **Emergency Prioritization**
9. **Natural Language to Query**

---

## Code Example: Enhanced "Ask SafeSeasons" with Streaming

Here's how to enhance the current implementation with streaming:

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
extension FoundationModelsAskUseCase {
    func streamAsk(question: String, context: AskContext) async throws -> AsyncThrowingStream<String, Error> {
        guard isAppleIntelligenceAvailable() else {
            throw AskError.appleIntelligenceUnavailable
        }
        
        let instructions = buildInstructions(context: context)
        let model = SystemLanguageModel.default
        let session = LanguageModelSession(
            model: model,
            instructions: { instructions },
            tools: [GetContextualTipsTool(offlineAIUseCase: offlineAIUseCase)]
        )
        
        let stream = try await session.streamResponse(
            options: GenerationOptions(temperature: 0.6, maximumResponseTokens: 512)
        ) {
            question
        }
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
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
}
#endif
```

**UI Integration:**
```swift
// In HomeViewModel
@Published var streamingResponse: String = ""

func streamAsk(question: String) {
    Task {
        streamingResponse = ""
        do {
            for try await chunk in askUseCase.streamAsk(question: question, context: context) {
                await MainActor.run {
                    streamingResponse += chunk
                }
            }
        } catch {
            await MainActor.run {
                askError = error.localizedDescription
            }
        }
    }
}
```

---

## Best Practices

1. **Always check availability:**
   ```swift
   guard SystemLanguageModel.default.availability == .available else {
       // Fallback to rule-based
   }
   ```

2. **Use appropriate temperature:**
   - Classification/Routing: `0.2-0.3` (deterministic)
   - Q&A: `0.6-0.8` (balanced)
   - Creative/Summarization: `0.7-0.9` (varied)

3. **Credit attribution:**
   - Always show "Powered by Apple foundational models" when using FM
   - Link to Apple Intelligence documentation if needed

4. **Graceful fallback:**
   - Always have rule-based fallback
   - Don't break on older devices

5. **Privacy:**
   - All processing is on-device
   - No data sent to Apple
   - User data stays private

---

## References

- [Foundation Models Documentation](https://developer.apple.com/documentation/foundationmodels)
- [Guided Generation](https://developer.apple.com/documentation/foundationmodels/guided-generation)
- [Streaming Responses](https://developer.apple.com/documentation/foundationmodels/streaming-responses)
- [Tool Calling](https://developer.apple.com/documentation/foundationmodels/tool-calling)
