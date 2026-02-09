//
//  DisasterReadyApp.swift
//  DisasterReady
//

import SwiftUI

@main
struct DisasterReadyApp: App {
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
                .environmentObject(container.extendedFeatures)
                .environmentObject(tabSelection)
                .onAppear {
                    // Deferred: initialize Foundation Models off the main thread
                    // so the app renders immediately without blocking on
                    // FoundationModels framework metadata resolution.
                    // Extra 0.5s delay avoids potential deadlock between FM
                    // dylib loading and the main thread during initial render.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        container.initializeFoundationModelsIfAvailable()
                    }
                }
        }
    }
}
