# SafeSeasons Offline AI — Architecture & MVP Plan

**Why offline AI?**  
*“Disasters often break connectivity. Offline-first design ensures preparedness and safety information is available when people need it most.”*

**Implementation status:** Phase 1 (rule-based contextual guidance) is implemented: `OfflineAIData` (rules + narratives), `OfflineAIRuleEngine`, `OfflineAIUseCase`, and “This month in [State]” tips on Home.

**Apple Foundation Models:** For on-device generative AI (content generation, tool calling, streaming), see [FOUNDATION_MODELS_WALKTHROUGH.md](FOUNDATION_MODELS_WALKTHROUGH.md).

---

## 1. What We Use

- **Rule engines + decision trees** — no external APIs for core logic.
- **Preloaded data** — regional profiles, seasonal risks, preparedness rules, risk narratives (already in `EmbeddedData`).
- **Local storage** — `UserDefaults` / `KeyValueStoring`, `ImageStoring`, SQLite if we add richer persistence.
- **Apple on-device AI** (optional, where we choose to use it):  
  - Foundation Models / Apple Intelligence, App Intents, etc.  
  - **Credit:** *“Powered by Apple foundational models”* or similar, per your requirement.

We **do not** use live predictions, real-time chat, or community trend analysis offline.

---

## 2. Offline AI Features (Priority Order)

### **#1 — Rule-based contextual guidance (MVP)**

**Inputs:** `Location` (state) + `Month` + `Risk` (from `StateRisk` / `SeasonalRisk`).

**Rules (examples):**

- If **Texas** + **May** + **Flooding/Tornadoes** →  
  - *“Flash flooding is common this month.”*  
  - *“Avoid underpasses and low-water crossings.”*  
  - *“Emergency kit should include waterproof documents.”*

**Implementation:**  
- `OfflineAIRuleEngine`: pure Swift, uses `EmbeddedData.states`, `SeasonalRisk`, disaster categories.  
- Matches (state, month, hazards) → returns prewritten “risk narratives” + tips.  
- No network, no external AI for this path.

**Data:**  
- Regional disaster profiles, seasonal patterns → already in `EmbeddedData`.  
- Add a small **rules table** (e.g. JSON or Swift enums): `(stateAbbr, month, hazard) → [narrative IDs]` and a **narratives store** (prewritten strings).

---

### **#2 — Preloaded risk narratives**

**Idea:** Pre-authored content for each (disaster × context). “AI” only **selects** which narrative to show.

**Examples:**

- *“Wildfire nearby”* → choose among: *“Stay indoors”*, *“Seal windows”*, *“Prepare to evacuate”*.
- *“Flash flood warning”* → *“Never drive through flooded roads”*, *“Move to higher ground.”*

**Implementation:**  
- Extend `EmbeddedData` (or a new `RiskNarratives` module) with `[DisasterType, Context] → [String]`.  
- Rule engine picks context (state + month + hazard) and returns the right narrative set.  
- **No generation**, no hallucination — only selection.

---

### **#3 — Offline “Disaster Mode”**

**Trigger:** Connectivity lost (e.g. `NWPathMonitor`); optionally user-toggle.

**Behavior:**

- UI switches to **Disaster Mode**: simplified, high-contrast, fewer taps.
- **Rule engine** drives what we show: prioritized steps, evacuation tips, kit reminders.
- **Cached data only:**  
  - Evacuation routes (preloaded, e.g. from EmbeddedData or future SQLite).  
  - Shelters / resources (existing `EmergencyResource` + map).  
  - Safety instructions = preloaded risk narratives.

**UX:**

- **“Offline mode active”**  
- **“Using last known data”**  
- **“Some features limited”**

---

### **#4 — Offline personalized checklists**

**When online (once):**

- User answers 3–5 questions (household size, pets, medical needs, etc.).
- App derives a **personalized plan** (e.g. which checklist items to emphasize, extra tips).
- Plan stored **locally** (e.g. `KeyValueStoring` / UserDefaults).

**When offline:**

- Same rule engine + **user profile** (from local storage) adapts:
  - Which checklist items to surface first.
  - Short tips (e.g. “Include pet supplies”) from prewritten copy.

**Implementation:**  
- `UserPreparednessProfile`: codable, persisted.  
- Rules keyed by `(state, month, hazard, profile)` → narrative IDs + checklist overrides.  
- Still 100% rule-based; no live generation.

---

## 3. What AI **Cannot** Do Offline (We Be Honest)

- ❌ Live predictions  
- ❌ Real-time chat  
- ❌ Community trend analysis  
- ❌ Up-to-the-minute alerts  

We don’t promise these offline. UI copy and docs should say so.

---

## 4. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  UI Layer                                                        │
│  • Normal UI / Disaster Mode UI                                  │
│  • “Offline mode active” / “Using last known data” banners       │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│  Offline AI / Rule Layer                                         │
│  • OfflineAIRuleEngine (state, month, hazard, profile → rules)   │
│  • Risk narrative selector (preloaded content only)              │
│  • Optional: Apple on-device AI where we integrate it            │
│    → “Powered by Apple foundational models”                      │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│  Data & Storage                                                  │
│  • EmbeddedData (states, seasonal risks, disasters, resources)   │
│  • Risk narratives (preloaded)                                   │
│  • UserPreparednessProfile (local)                               │
│  • KeyValueStoring / ImageStoring / future SQLite                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. MVP Recommendation

**Phase 1 (first slice):**

1. **Rule-based contextual tips**  
   - Implement `OfflineAIRuleEngine`.  
   - Use `(state, month, hazards)` from existing models.  
   - Add a small **rules + narratives** dataset (Swift or JSON).  
   - Surface 2–3 tips on Home (e.g. “This month in Texas”) and/or Browse.

2. **“Offline mode active” UX**  
   - `NWPathMonitor` → detect offline.  
   - Show a compact banner: **“Offline mode active · Using last known data”** and optionally **“Some features limited.”**  
   - Gate any future online-only features clearly.

**Phase 2:**

3. **Disaster Mode**  
   - Simplified UI when offline (or when user enables it).  
   - Reuse same rule engine + preloaded narratives for prioritization and safety text.

4. **Preloaded risk narratives**  
   - Expand `EmbeddedData` / RiskNarratives.  
   - Wire rule engine → narrative selector for Disaster Mode and disaster-specific screens.

**Phase 3:**

5. **Offline personalized checklists**  
   - 3–5 onboarding questions.  
   - `UserPreparednessProfile` + persistence.  
   - Rules that adapt checklist and tips by profile.

---

## 6. Apple built-in AI

- Use **only** where we explicitly add it (e.g. optional summarization, or future App Intents).  
- **Credit:** *“Powered by Apple foundational models”* (or equivalent) in UI/settings/docs when we do.  
- **Offline rule-based logic** does not require Apple AI; keep it separate so the app stays fully offline-capable without it.

---

## 7. UX Copy (Summary)

- **“Offline mode active”** — when we detect no connectivity.  
- **“Using last known data”** — when showing cached state/resources.  
- **“Some features limited”** — when we hide or disable online-only features.  
- **“Why offline AI?”** — use the one-liner above in onboarding or About.

---

## 8. Next Steps

1. **MVP:** Implement `OfflineAIRuleEngine` + minimal rules + narratives, and expose 2–3 contextual tips on Home.  
2. **UX:** Add `NWPathMonitor` + “Offline mode active” (and related) banners.  
3. **Design:** Optionally add an architecture diagram (e.g. Mermaid) under `docs/` for presentations.

If you want to proceed, we can next **define the exact rule schema** (state + month + hazard → narrative IDs) and **add the first rules + narratives** into the codebase.
