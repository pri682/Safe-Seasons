//
//  RootView.swift
//  SafeSeasons
//
//  Tab container. No business logic; depends on child views' ViewModels via environment.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var tabSelection: TabSelectionHolder

    var body: some View {
        TabView(selection: $tabSelection.selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            BrowseView()
                .tabItem { Label("Browse", systemImage: "list.bullet") }
                .tag(1)
            ChecklistView()
                .tabItem { Label("Checklist", systemImage: "checklist") }
                .tag(2)
            MapView()
                .tabItem { Label("Map", systemImage: "map.fill") }
                .tag(3)
            AlertsView()
                .tabItem { Label("Alerts", systemImage: "bell.fill") }
                .tag(4)
        }
        .tint(AppColors.ctaGreen)
        .onOpenURL { url in
            guard url.scheme == "safeseasons", let host = url.host else { return }
            switch host {
            case "map": tabSelection.selectedTab = 3
            case "checklist": tabSelection.selectedTab = 2
            default: break
            }
        }
    }
}

#Preview {
    let c = DependencyContainer()
    return RootView()
        .environmentObject(c.homeViewModel)
        .environmentObject(c.browseViewModel)
        .environmentObject(c.checklistViewModel)
        .environmentObject(c.mapViewModel)
        .environmentObject(c.alertsViewModel)
        .environmentObject(TabSelectionHolder())
}
