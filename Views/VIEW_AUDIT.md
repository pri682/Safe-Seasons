# SafeSeasons Views — What Each File Does

## SOLID (see `SOLID_PRINCIPLES.md`)

- **Views** depend only on their **ViewModel** (`@EnvironmentObject`). No DataManager, no use cases.
- **ViewModels** live in `ViewModels/`; each depends on **use-case protocols** only.

## Shared (stay in `Views/`)

| File | Role |
|------|------|
| **RootView.swift** | Tab bar container. Hosts Home, Browse, Checklist, Map, Alerts. No business logic. |
| **Theme+Helpers.swift** | Shared UI: `RiskLevel.color`, `categoryColor`, `ChecklistItem.Priority.color`, `EmergencyResource.ResourceType` icon/color/uiColor, `CategorySectionHeader`, `BrowseDisasterRow`. |

## Tab-specific (one per folder: `Views/{Tab}/{Tab}View.swift`)

| File | Role |
|------|------|
| **Home/HomeView.swift** | Home tab. Uses `HomeViewModel`. Contains `QuickActionButton`, `StatePickerSheet`. |
| **Browse/BrowseView.swift** | Browse tab. Uses `BrowseViewModel`. Contains `BrowseInfoSheet`, `QuickActionSheet`, `DisasterDetailView`, `DisasterDetailSection`. |
| **Checklist/ChecklistView.swift** | Checklist tab. Uses `ChecklistViewModel`. Contains `PhotoPickerContext`, `ChecklistRowView`, `PhotoPickerSheet`, `LocalImageView`. |
| **Map/MapView.swift** | Map tab. Uses `MapViewModel`. Contains `MapViewRepresentable`, `ResourceAnnotation`, `LegendRow`. |
| **Alerts/AlertsView.swift** | Alerts tab. Uses `AlertsViewModel`. Contains `WEAVerificationRow`, `WEAEducationDetailView`. |

## Rules

- **One view file per tab.** Each tab has exactly one folder and one `*View.swift` inside it.
- **No duplicates.** Do not add `HomeView.swift` (or any tab view) both in `Views/` and in `Views/Home/`.
- **No god objects.** Views use only their ViewModel; ViewModels use only use-case protocols.
