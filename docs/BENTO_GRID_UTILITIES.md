# Bento Grid & Offline Utility Tools — Implementation Summary

## Overview

Redesigned **HomeView** with a **Bento Grid layout** (Apple Home app style) and replaced generic "Quick Actions" with **offline utility tools** that work without internet.

---

## Part 1: New Offline Utility Tools

### 1. **Digital Beacon** (Replaces "Call 911" generic action)

**Location:** `Views/Utilities/DigitalBeaconView.swift`

**Features:**
- **SOS Morse code** flashlight pattern: `••• --- •••` (S-O-S)
- Uses device **torch** (AVFoundation)
- **Full-screen** view with dark background when active
- **Start/Stop** controls
- **Offline** — no network required

**UI:**
- Large flashlight icon
- "Start SOS Beacon" / "Stop Beacon" button
- Visual feedback (pulsing icon when active)
- Instructions: "Hold device high and visible"

**How it works:**
- Dot = 0.2s flash, Dash = 0.6s flash
- Pattern: S (•••) → pause → O (---) → pause → S (•••)
- Repeats continuously until stopped

---

### 2. **Evacuation Drill** (Replaces "Emergency Guide" PDF)

**Location:** `Views/Utilities/EvacuationDrillView.swift`

**Features:**
- **2-minute countdown timer**
- **Interactive checklist** (6 items):
  - Keys
  - Wallet
  - Medications
  - Phone
  - Documents
  - Water
- **Gamified** — user checks items as they gather them
- **Completion feedback** — shows how many items checked

**UI:**
- **Start screen:** Instructions + "Start Drill" button
- **Active drill:** Large timer (red when < 30s), checklist with checkboxes
- **Completed:** Success message + "Try Again" button

**Why it's better:**
- **Interactive** — not just reading
- **Practice** — builds muscle memory
- **Time pressure** — realistic simulation

---

### 3. **Compass & Coordinates** (Replaces "Find Help" generic link)

**Location:** `Views/Utilities/CompassCoordinatesView.swift`

**Features:**
- **Compass** with cardinal directions (N, E, S, W)
- **Current coordinates** (Latitude/Longitude) — 6 decimal precision
- Uses **CoreLocation** (offline after initial permission)
- **LocationManager** class handles permissions and updates

**UI:**
- Large compass circle (200x200)
- Red north needle (rotates with heading)
- Two cards: Latitude + Longitude (monospaced font)
- Permission prompt if needed

**Why it's better:**
- **Real survival tool** — coordinates can be shared with rescuers
- **Works offline** — CoreLocation doesn't need network
- **Visual compass** — helps with navigation

---

## Part 2: Bento Grid Layout

### Design Principles

1. **Grid Layout** — 2-column cards (like Apple Home app)
2. **Visual Depth** — Shadows (`radius: 12, y: 4`), rounded corners (`24pt`)
3. **Big Typography** — Large numbers (e.g., `32pt bold` for hazard count)
4. **Grouped Cards** — Related items in same row
5. **Color Coding** — Each card has distinct icon/color

### Grid Structure

```
Row 1: Emergency CTA (full width, red gradient)
Row 2: State Selection | Risk Overview
Row 3: Contextual Tips (full width, if present)
Row 4: Digital Beacon | Evacuation Drill
Row 5: Compass & Coordinates | Checklist
Row 6: Map | Ask SafeSeasons
```

### Card Styling

- **Background:** `AppColors.cardBg` (white/light gray)
- **Corner Radius:** `24pt`
- **Shadow:** `black.opacity(0.06), radius: 12, x: 0, y: 4`
- **Padding:** `20pt`
- **Spacing:** `16pt` between cards

### Typography Hierarchy

- **Large Numbers:** `.system(size: 32, weight: .bold, design: .rounded)` (hazard count)
- **Headlines:** `.headline` (card titles)
- **Captions:** `.caption` (subtitles)
- **Emergency CTA:** `.title2.weight(.bold)` (white on red)

---

## Implementation Details

### Files Created

1. **`Views/Utilities/DigitalBeaconView.swift`**
   - SOS flashlight controller
   - AVFoundation torch control
   - Morse code timing logic

2. **`Views/Utilities/EvacuationDrillView.swift`**
   - Timer with `Timer.scheduledTimer`
   - Checklist state management
   - Completion feedback

3. **`Views/Utilities/CompassCoordinatesView.swift`**
   - `LocationManager` (CLLocationManagerDelegate)
   - Compass rendering
   - Coordinate formatting

### Files Modified

1. **`Views/Home/HomeView.swift`**
   - Complete redesign with Bento Grid
   - New card components
   - Full-screen covers for utilities

2. **`Info.plist`**
   - Added `NSLocationWhenInUseUsageDescription`
   - Added `NSCameraUsageDescription` (for flashlight)

---

## Testing

### Digital Beacon
1. Tap "Digital Beacon" card
2. Tap "Start SOS Beacon"
3. Verify flashlight flashes in SOS pattern
4. Tap "Stop Beacon"
5. Verify flashlight turns off

### Evacuation Drill
1. Tap "Evacuation Drill" card
2. Tap "Start Drill"
3. Verify 2-minute timer starts
4. Check items as you "gather" them
5. Verify completion screen shows results

### Compass & Coordinates
1. Tap "Compass & Coordinates" card
2. Grant location permission (first time)
3. Verify compass shows north
4. Verify coordinates display (lat/long)
5. Rotate device — compass should update

### Bento Grid
1. Verify cards are in 2-column layout
2. Verify full-width cards (Emergency CTA, Contextual Tips) span both columns
3. Verify shadows and rounded corners
4. Verify spacing between cards
5. Test on iPad — should use space better than old vertical list

---

## Permissions Required

- **Location (When In Use):** For Compass & Coordinates
- **Camera (Flashlight):** For Digital Beacon (iOS uses camera permission for torch)

Both are requested at runtime when the user opens the respective utility.

---

## Offline Capability

All three utilities work **completely offline**:
- **Digital Beacon:** Uses device hardware (flashlight)
- **Evacuation Drill:** Pure UI logic (timer + checklist)
- **Compass & Coordinates:** CoreLocation works offline (GPS doesn't need network)

---

## Next Steps (Optional Enhancements)

1. **Screen flash** for Digital Beacon (in addition to flashlight)
2. **Custom drill items** (user can add their own)
3. **Drill history** (save best times)
4. **Share coordinates** (copy to clipboard or share sheet)
5. **Compass calibration** (if heading is inaccurate)
