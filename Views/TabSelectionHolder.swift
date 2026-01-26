//
//  TabSelectionHolder.swift
//  SafeSeasons
//
//  Holds selected tab index so Home quick actions can switch tabs.
//

import SwiftUI

final class TabSelectionHolder: ObservableObject {
    @Published var selectedTab: Int = 0
}
