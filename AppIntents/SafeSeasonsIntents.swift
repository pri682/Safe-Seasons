//
//  SafeSeasonsIntents.swift
//  SafeSeasons
//
//  App Intents for Siri Shortcuts: Call 911, Open Map, Show Checklist.
//

import AppIntents
import SwiftUI
import UIKit

struct Call911Intent: AppIntent {
    static var title: LocalizedStringResource { "Call 911" }
    static var description: IntentDescription { IntentDescription("Open the phone dialer to call 911 for emergencies.") }
    static var openAppWhenRun: Bool { false }

    @MainActor
    func perform() async throws -> some IntentResult {
        if let url = URL(string: "tel:911") {
            await UIApplication.shared.open(url)
        }
        return .result()
    }
}

struct OpenEmergencyMapIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Emergency Map" }
    static var description: IntentDescription { IntentDescription("Open SafeSeasons and show the emergency resources map.") }
    static var openAppWhenRun: Bool { true }

    @MainActor
    func perform() async throws -> some IntentResult {
        if let url = URL(string: "safeseasons://map") {
            await UIApplication.shared.open(url)
        }
        return .result()
    }
}

struct ShowChecklistIntent: AppIntent {
    static var title: LocalizedStringResource { "Show Preparedness Checklist" }
    static var description: IntentDescription { IntentDescription("Open SafeSeasons and show your emergency preparedness checklist.") }
    static var openAppWhenRun: Bool { true }

    @MainActor
    func perform() async throws -> some IntentResult {
        if let url = URL(string: "safeseasons://checklist") {
            await UIApplication.shared.open(url)
        }
        return .result()
    }
}

struct SafeSeasonsShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: Call911Intent(),
            phrases: ["Call 911 in \(.applicationName)", "Emergency call in \(.applicationName)"],
            shortTitle: "Call 911",
            systemImageName: "phone.fill"
        )
        AppShortcut(
            intent: OpenEmergencyMapIntent(),
            phrases: ["Open emergency map in \(.applicationName)", "Show map in \(.applicationName)"],
            shortTitle: "Open Map",
            systemImageName: "map.fill"
        )
        AppShortcut(
            intent: ShowChecklistIntent(),
            phrases: ["Show checklist in \(.applicationName)", "Open checklist in \(.applicationName)"],
            shortTitle: "Show Checklist",
            systemImageName: "checklist"
        )
    }
}
