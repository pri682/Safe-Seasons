//
//  SafeSeasonsApp.swift
//  SafeSeasons
//

import SwiftUI

@main
struct SafeSeasonsApp: App {
    @State private var container = DependencyContainer()
    @StateObject private var tabSelection = TabSelectionHolder()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container.homeViewModel)
                .environmentObject(container.browseViewModel)
                .environmentObject(container.checklistViewModel)
                .environmentObject(container.mapViewModel)
                .environmentObject(container.alertsViewModel)
                .environmentObject(tabSelection)
        }
    }
}
