# SafeSeasons

A comprehensive disaster preparedness iOS app that adapts to different seasonal risks based on your location - monsoons, hurricanes, tornadoes, wildfires, floods, blizzards, etc.

## Features

### 🏠 Home Tab
- **State Selection**: Choose your state to get location-specific preparedness information
- **Risk Overview**: View top hazards and risk levels for your selected state
- **Quick Actions**: Offline utility tools including:
  - **Digital Beacon**: SOS Morse code flashlight for emergency signaling
  - **Evacuation Drill**: Interactive 2-minute practice drill
  - **Compass & Coordinates**: GPS coordinates and compass heading (offline)
- **Ask SafeSeasons**: AI-powered conversational assistant for preparedness questions
  - Real-time streaming responses
  - Context-aware answers based on your state and current month
  - Powered by Apple Foundation Models (when available)

### 📚 Browse Tab
- Red Cross-style disaster categories with expandable sections
- Search functionality for disasters
- Detailed information for each disaster type

### ✅ Checklist Tab
- Interactive preparedness checklist with progress tracking
- Photo upload support for documentation
- Priority levels for supplies

### 🗺️ Map Tab
- Emergency resources map with legend
- Location-based emergency services

### 🚨 Alerts Tab
- WEA (Wireless Emergency Alerts) verification
- Seasonal reminders
- WEA education content
- Offline NWS-style weather alerts (preloaded templates)

## Technical Architecture

### SOLID Principles
The app strictly follows SOLID principles:
- **Single Responsibility Principle (SRP)**: Each class has one reason to change
- **Open/Closed Principle (OCP)**: Open for extension, closed for modification
- **Liskov Substitution Principle (LSP)**: Subtypes are substitutable for their base types
- **Interface Segregation Principle (ISP)**: Clients depend only on interfaces they use
- **Dependency Inversion Principle (DIP)**: Depend on abstractions, not concretions

### Architecture Pattern
- **MVVM (Model-View-ViewModel)**: Clean separation of concerns
- **Dependency Injection**: All dependencies injected via `DependencyContainer`
- **Repository Pattern**: Data access abstraction
- **Use Case Pattern**: Business logic encapsulation

### Offline-First Design
- All data is embedded and works completely offline
- No network calls required for core functionality
- Preloaded disaster information, checklists, and emergency resources

### Apple Foundation Models Integration
- **Streaming Responses**: Real-time text generation
- **Guided Generation**: Structured output (PreparednessPlan, Checklists, etc.)
- **Content Tagging**: Question classification and routing
- **Multi-turn Conversations**: Context-aware chat sessions
- **Summarization**: Condensed disaster information
- **Emergency Prioritization**: Action ranking by urgency
- **Query Parsing**: Natural language to structured queries

All Foundation Models features gracefully fall back to rule-based implementations when Apple Intelligence is unavailable.

## Requirements

- iOS 16.0+
- Xcode 15.0+
- For Foundation Models features: iOS 26.0+ with Apple Intelligence-enabled device

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/SafeSeasons.git
cd SafeSeasons
```

2. Open in Xcode:
```bash
open SafeSeasons.swiftpm
```

3. Build and run (⌘R)

## Project Structure

```
SafeSeasons.swiftpm/
├── AppIntents/              # App Intents
├── Data/                    # JSON data files
├── DI Container/            # Dependency Injection & Domain Layer
│   ├── Data/               # Repositories & Data Sources
│   ├── Domain/             # Entities & Use Cases
│   └── Infrastructure/     # Storage implementations
├── Dependency Injections/  # Dependency Container
├── ViewModels/             # MVVM ViewModels
├── Views/                  # SwiftUI Views
│   ├── Home/
│   ├── Browse/
│   ├── Checklist/
│   ├── Map/
│   ├── Alerts/
│   └── Utilities/
└── docs/                   # Documentation
```

## Data Sources & Attribution

- **FEMA (Federal Emergency Management Agency)**: Preparedness tips and safety guidance
- **NWS (National Weather Service)**: Weather alert formats and terminology
- **Official Resources**:
  - [FEMA Ready.gov](https://www.ready.gov)
  - [NWS Weather.gov](https://www.weather.gov)
  - [FCC Wireless Emergency Alerts](https://www.fcc.gov/wireless-emergency-alerts)

## Credits

- **Apple Foundation Models**: On-device AI capabilities (iOS 26+)
- **Apple Intelligence**: Privacy-first AI processing
- **FEMA & NWS**: Disaster preparedness information and safety guidance

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]
