# Testing Offline Weather Alerts

## Quick Test Steps

### 1. **Basic Flow Test**

1. **Launch the app** → Go to **Home** tab
2. **Select a state** that has alerts (e.g., **Texas**)
3. **Go to Alerts tab** → You should see a **"Weather Alerts"** section
4. **Verify** alerts match the current month:
   - **January** → Should show "Extreme Cold Warning" for Texas
   - **May** → Should show "Tornado Watch" for Texas
   - **July** → Should show "Extreme Heat Warning" for Texas
   - **September** → Should show "Hurricane Warning" for Texas

### 2. **State + Month Combinations**

| State | Month | Expected Alert |
|-------|-------|----------------|
| **Texas** | January | Extreme Cold Warning |
| **Texas** | May | Tornado Watch |
| **Texas** | July | Extreme Heat Warning |
| **Texas** | September | Hurricane Warning |
| **Oklahoma** | May | Tornado Watch |
| **Oklahoma** | January | Winter Storm Warning |
| **California** | July | Red Flag Warning (Wildfire) |
| **California** | January | Flash Flood Watch |
| **Florida** | September | Hurricane Warning |
| **Colorado** | January | Blizzard Warning |
| **Arizona** | July | Excessive Heat Warning |

### 3. **Edge Cases**

- **No state selected** → Alerts section should **not appear**
- **State with no alerts for current month** (e.g., Texas in November) → Alerts section should **not appear**
- **State not in templates** (e.g., Alaska) → No alerts shown

### 4. **UI Verification**

- ✅ **"Weather Alerts"** section header appears when alerts exist
- ✅ **Alert cards** show:
  - Severity icon (red for extreme, orange for severe)
  - Alert title (e.g., "Extreme Cold Warning")
  - Area + Source (e.g., "Texas • National Weather Service")
  - Full description text
- ✅ **Severity colors**:
  - Extreme → Red border/background
  - Severe → Orange border/background
  - Moderate → Yellow border/background

---

## Testing Different Months (Manual Override)

To test alerts for different months without changing your device date:

### Option A: Add a Debug Month Override

Add this to `AlertsViewModel` for testing:

```swift
// In AlertsViewModel.swift
#if DEBUG
var debugMonth: String? = nil // Set to "January", "May", etc. for testing
#endif

func load() {
    // ... existing code ...
    let month = #if DEBUG
        debugMonth ?? currentMonthProvider()
    #else
        currentMonthProvider()
    #endif
    weatherAlerts = weatherAlertUseCase.getAlerts(state: state, month: month)
}
```

Then in Xcode debugger or a test view, set:
```swift
viewModel.debugMonth = "January" // Test winter alerts
```

### Option B: Use Xcode Scheme Environment Variable

1. **Edit Scheme** → **Run** → **Arguments** → **Environment Variables**
2. Add: `TEST_MONTH` = `"January"` (or any month)
3. In `AlertsViewModel.load()`:
```swift
let month = ProcessInfo.processInfo.environment["TEST_MONTH"] ?? currentMonthProvider()
```

### Option C: Change Device Date (iOS Simulator)

1. **Settings** → **General** → **Date & Time**
2. Turn off **Set Automatically**
3. Set date to a month you want to test (e.g., January 15, 2026)
4. Restart app or call `viewModel.load()` again

---

## Automated Testing (Unit Tests)

Create a test file:

```swift
import XCTest
@testable import SafeSeasons

final class WeatherAlertTests: XCTestCase {
    var repository: WeatherAlertRepository!
    var useCase: WeatherAlertUseCase!
    
    override func setUp() {
        repository = WeatherAlertRepository()
        useCase = WeatherAlertUseCase(repository: repository)
    }
    
    func testTexasJanuaryShowsExtremeCold() {
        let state = StateRisk(name: "Texas", abbreviation: "TX", riskLevel: .high, topHazards: [], seasonalRisks: [])
        let alerts = useCase.getAlerts(state: state, month: "January")
        
        XCTAssertFalse(alerts.isEmpty, "Should have alerts for Texas in January")
        XCTAssertTrue(alerts.contains { $0.type == .extremeCold }, "Should include Extreme Cold Warning")
    }
    
    func testTexasMayShowsTornado() {
        let state = StateRisk(name: "Texas", abbreviation: "TX", riskLevel: .high, topHazards: [], seasonalRisks: [])
        let alerts = useCase.getAlerts(state: state, month: "May")
        
        XCTAssertTrue(alerts.contains { $0.type == .tornado }, "Should include Tornado Watch")
    }
    
    func testNoStateReturnsEmpty() {
        let alerts = useCase.getAlerts(state: nil, month: "January")
        XCTAssertTrue(alerts.isEmpty, "No state should return no alerts")
    }
    
    func testAlaskaNoAlerts() {
        let state = StateRisk(name: "Alaska", abbreviation: "AK", riskLevel: .moderate, topHazards: [], seasonalRisks: [])
        let alerts = useCase.getAlerts(state: state, month: "January")
        XCTAssertTrue(alerts.isEmpty, "Alaska has no preloaded alerts")
    }
}
```

---

## Visual Testing Checklist

- [ ] **Alerts section appears** when state is selected and month has alerts
- [ ] **Alerts section hidden** when no state or no matching alerts
- [ ] **Severity colors** are correct (red/orange/yellow)
- [ ] **Icons** match severity (exclamationmark.triangle.fill for extreme)
- [ ] **Text is readable** (title, area, source, description)
- [ ] **Cards are properly styled** (rounded corners, borders, padding)
- [ ] **Multiple alerts** stack vertically with spacing
- [ ] **ScrollView** works when many alerts are present

---

## Quick Test Script

1. **Home** → Select **Texas**
2. **Alerts** → Should see alerts for current month
3. **Home** → Select **Oklahoma**
4. **Alerts** → Should see different alerts (or none if month doesn't match)
5. **Home** → Select **Alaska** (or any state with no templates)
6. **Alerts** → Should see no "Weather Alerts" section
7. **Home** → Clear state selection (if possible)
8. **Alerts** → Should see no "Weather Alerts" section

---

## Debugging Tips

- **Check console logs** if alerts don't appear:
  - Verify `viewModel.weatherAlerts` is populated in `load()`
  - Check `stateRiskUseCase.getCurrentState()` returns expected state
  - Verify month string matches template months (e.g., "January" not "Jan")

- **Verify templates** in `EmbeddedData.weatherAlertTemplates`:
  - Count total templates (should be 18)
  - Check state abbreviations match (e.g., "TX" not "Texas")
  - Check month names match exactly (e.g., "January" not "Jan")

- **Test repository directly**:
```swift
let repo = WeatherAlertRepository()
let alerts = repo.fetchAlerts(stateAbbr: "TX", month: "January")
print("Found \(alerts.count) alerts for TX in January")
```
