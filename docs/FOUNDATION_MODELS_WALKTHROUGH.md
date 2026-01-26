# Foundation Models Walkthrough — Apple Developer Documentation

Summary of [Apple’s Foundation Models framework](https://developer.apple.com/documentation/foundationmodels) for **generating content and performing tasks** with on-device language models. References: [Apple Developer Documentation](https://developer.apple.com/documentation/foundationmodels), [Create with Swift — Exploring the Foundation Models framework](https://createwithswift.com/exploring-the-foundation-models-framework), [WWDC 2025 sessions](https://developer.apple.com/videos/play/wwdc2025/286/).

---

## 1. Overview

The **Foundation Models** framework gives you access to the **on-device large language models** that power **Apple Intelligence**. It runs on **macOS, iOS, iPadOS, and visionOS**, with:

- **Privacy-first, on-device** inference (Apple silicon: CPU/GPU/Neural Engine)
- **Offline-capable** generation — no network required for `SystemLanguageModel.default`; inference runs locally
- **No extra app size** — models are part of the OS
- **Swift API** via `import FoundationModels`

**Offline?** Yes. The **on-device** model (`SystemLanguageModel.default`) runs entirely on device. No data is sent to Apple for inference. SafeSeasons uses only this path; the “Ask SafeSeasons” flow (including the `getContextualTips` tool) works fully offline when Apple Intelligence is available.

Available from **iOS 26** (and equivalent OS versions). Requires **Apple Intelligence–enabled devices**; always check `model.availability` before use.

---

## 2. System language model

**`SystemLanguageModel`** is the entry point to Apple’s built-in LLM.

```swift
import FoundationModels

// Base model — general text generation, Q&A, creative tasks
let generalModel = SystemLanguageModel.default

// Specialized adapter — tagging, extraction, classification
let taggingModel = SystemLanguageModel(useCase: .contentTagging)
```

- **`.default`**: general-purpose generation and question answering.
- **`useCase: .contentTagging`**: fine-tuned for topic tags, entity extraction, classification.

**Availability:** The model is only usable on supported devices with Apple Intelligence. Check before creating a session:

```swift
let model = SystemLanguageModel.default
switch model.availability {
case .available:
    // Ready to use
case .unavailable(let reason):
    // e.g. device not eligible, Apple Intelligence off, model downloading
}
```

---

## 3. Language model session

**`LanguageModelSession`** is a **single conversation context**. It keeps the prompt/response history and lets you send prompts and get (or stream) replies.

```swift
// Minimal
let session = LanguageModelSession()

// With model, instructions, tools
let session2 = LanguageModelSession(
    model: taggingModel,
    guardrails: .default,
    tools: [myTool1, myTool2],
    instructions: {
        "You are a helpful assistant. Provide concise answers."
    }
)
```

**Parameters:**

| Parameter | Purpose |
|----------|---------|
| **model** | `SystemLanguageModel` to use (default: `.default`) |
| **guardrails** | Safety filters; `.default` applies Apple’s content guidelines (required) |
| **tools** | Custom `Tool` instances the model can call during generation |
| **instructions** | System prompt (string or `InstructionsBuilder`) to steer behavior |
| **transcript** | Optional previous `Transcript` to restore multi-turn context |

**Usage tips:**

- One session per chat / flow.
- Use **`prewarm(promptPrefix:)`** to load the model before the first user input.
- Use **`isResponding`** to disable input while the model is generating.

---

## 4. Generating a response

### 4.1 One-shot response (`respond`)

**`respond(to:options:)`** (and overloads) send a prompt and return a **full** reply.

```swift
// Plain text
let result = try await session.respond(to: "What are three key steps for flood preparedness?")
print(result.content)

// With options
let options = GenerationOptions(
    sampling: .greedy,
    temperature: 0.8,
    maximumResponseTokens: 200
)
let answer = try await session.respond(to: "Summarize…", options: options)
```

**`Response`** has:

- **`content`**: generated text (or decoded struct when using guided generation).
- **`transcriptEntries`**: conversation history (user + assistant messages).

### 4.2 Guided generation — structured output

Use **`@Generable`** types so the model returns **structured data** instead of raw text.

```swift
@Generable
struct WeatherReport: Equatable {
    let temperature: Double
    let condition: String
    let humidity: Double
}

let result = try await session.respond(
    to: Prompt("Provide today's weather."),
    generating: WeatherReport.self,
    includeSchemaInPrompt: false,
    options: GenerationOptions(temperature: 0.5)
)
let report: WeatherReport = result.content
```

- **`generating:`** — your `@Generable` type.
- **`includeSchemaInPrompt`** — whether to add the JSON schema to the prompt (default `true`).
- **`options`** — e.g. `temperature`, `maximumResponseTokens`, `sampling`.

### 4.3 Constraining output with `@Guide`

**`@Guide`** adds hints or constraints per property:

```swift
@Generable
struct Movie {
    let title: String
    @Guide(description: "An action movie genre")
    let genre: String
    @Guide(.anyOf(["PG-13", "R", "PG", "G"]))
    let rating: String
}
```

- **`description`** — natural-language cue for the model.
- **`.anyOf([...])`** — restrict to specific values.
- **`.count(n)`** — array length.
- **Regex** — pattern for strings.

---

## 5. Streaming responses

**`streamResponse`** returns an **`AsyncSequence`** of **partially generated** values instead of a single final response.

```swift
let stream = try await session.streamResponse(
    generating: MyStruct.self,
    options: GenerationOptions(),
    includeSchemaInPrompt: false
) {
    "Please generate a report about SwiftUI views."
}

for try await partial in stream {
    // partial is MyStruct.PartiallyGenerated — fields filled over time
    updateUI(with: partial)
}
```

- **`T.PartiallyGenerated`**: same shape as `T`, but all properties **optional**; they populate as the model generates.
- Use this for **live UI updates** (e.g. SwiftUI) as content appears.

---

## 6. Generation options

**`GenerationOptions`** controls how the model generates:

- **`temperature`** (0.0–2.0): lower → more deterministic; higher → more varied.
- **`maximumResponseTokens`**: cap on output length.
- **`sampling`**:
  - **`.greedy`**: always pick most likely token — deterministic.
  - **`.random(probabilityThreshold:seed:)`** (top-p), **`.random(top:seed:)`** (top-k): controlled randomness; `seed` helps reproducibility.

---

## 7. Tools — model-callable code

**Tools** let the model **invoke your code** (e.g. fetch data, run logic) during generation.

You define a type conforming to **`Tool`** with:

- **`name`**: identifier (e.g. `"findRestaurants"`).
- **`description`**: what the tool does (used by the model to decide when to call it).
- **`Arguments`**: a **`@Generable`** struct for parameters.
- **`call(arguments:)`**: `async throws -> ToolOutput`.

```swift
final class FindRestaurantsTool: Tool {
    let name = "findRestaurants"
    let description = "Finds nearby restaurants based on a query."

    @Generable
    struct Arguments {
        @Guide(description: "The name or type of restaurant to search for.")
        let query: String
        @Guide(.count(3))
        let maxResults: Int
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        let list = ["Pasta Place", "Sushi Spot", "Burger Barn"]
        return ToolOutput(list.joined(separator: ", "))
    }
}
```

Pass tools into the session:

```swift
let session = LanguageModelSession(tools: [FindRestaurantsTool()])
```

The model **decides when** to call tools based on the conversation. **`ToolOutput`** can wrap a `String` or `GeneratedContent`. Results are fed back into the session so the model can use them in later turns.

---

## 8. Capabilities summary

| Feature | Description |
|--------|-------------|
| **Guided generation** | `@Generable` + `@Guide` → structured, type-safe output |
| **Streaming** | `streamResponse` → `AsyncSequence` of `T.PartiallyGenerated` |
| **Tool calling** | Model invokes your `Tool` implementations |
| **Stateful sessions** | Multi-turn context via `LanguageModelSession` + `Transcript` |

---

## 9. Relation to SafeSeasons

**Current setup:** SafeSeasons uses a **rule-based** Offline AI (rules table + narratives, no LLM) for “This month” tips and core safety content. That stays **fully offline**, **deterministic**, and **no device-capability checks**.

**Implemented:** **“Ask SafeSeasons”** (Home → Quick Action) lets users ask preparedness questions. When **Foundation Models** is available (iOS 26+, Apple Intelligence), answers use the on-device LLM with a **`getContextualTips`** tool that pulls from the rule engine. Otherwise, a **rule-based** fallback (keyword match → disaster steps / “This month” tips) is used. The sheet shows **“Powered by Apple foundational models”** only when FM was used.

**Optional enhancement:** Where you want more **generative** behavior:

1. **Check availability**  
   `SystemLanguageModel.default.availability == .available` (Apple Intelligence–enabled device).

2. **Use a dedicated session**  
   e.g. “Answer a preparedness question” or “Summarize this disaster’s steps” with `instructions` that reflect SafeSeasons context (state, hazards, etc.).

3. **Prefer guided generation**  
   Use `@Generable` structs for “list of tips”, “short summary”, etc., so output is predictable and easy to show in UI.

4. **Tools**  
   Optional tools could wrap **existing** logic (e.g. “get tips for state X and month Y”) so the model can pull from your rule engine or EmbeddedData when answering.

5. **Credit**  
   Per your requirements: surface **“Powered by Apple foundational models”** (or similar) when using Foundation Models.

**When to keep rule-based:**  
For **critical safety** content (e.g. “Call 911”, “Avoid underpasses”), **preloaded narratives** remain preferable: no hallucination, same message everywhere, works on all devices. Use Foundation Models for **supplementary** richness (explanations, Q&A, optional summaries) while keeping core guidance rule-based.

---

## 10. References

- [Foundation Models | Apple Developer Documentation](https://developer.apple.com/documentation/foundationmodels)
- [Generating content and performing tasks with Foundation Models](https://developer.apple.com/documentation/foundationmodels/generating-content-and-performing-tasks-with-foundation-models)
- [Exploring the Foundation Models framework](https://createwithswift.com/exploring-the-foundation-models-framework) (Create with Swift)
- [Meet the Foundation Models framework (WWDC 2025)](https://developer.apple.com/videos/play/wwdc2025/286/)
- [Code-along: Bring on-device AI to your app (WWDC 2025)](https://developer.apple.com/videos/play/wwdc2025/259/)
