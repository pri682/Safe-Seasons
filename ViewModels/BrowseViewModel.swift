//
//  BrowseViewModel.swift
//  SafeSeasons
//
//  SRP: Browse tab presentation. DIP: depends on DisasterUseCaseProtocol only.
//

import Foundation
import SwiftUI

final class BrowseViewModel: ObservableObject {
    @Published private(set) var categories: [DisasterCategory] = []
    @Published var searchText = ""

    private let disasterUseCase: DisasterUseCaseProtocol

    init(disasterUseCase: DisasterUseCaseProtocol) {
        self.disasterUseCase = disasterUseCase
    }

    func load() {
        categories = disasterUseCase.getAllCategories()
    }

    var filteredCategories: [DisasterCategory] {
        guard !searchText.isEmpty else { return categories }
        let synonymNames = DisasterSearchSynonyms.disasterNames(for: searchText)
        return categories.compactMap { cat in
            let filtered = cat.disasters.filter { disaster in
                disaster.name.localizedCaseInsensitiveContains(searchText)
                || synonymNames.contains(disaster.name)
            }
            guard !filtered.isEmpty else { return nil }
            return DisasterCategory(id: cat.id, name: cat.name, icon: cat.icon, color: cat.color, disasters: filtered)
        }
    }

    func disaster(byId id: UUID) -> Disaster? {
        disasterUseCase.getDisasterById(id)
    }
}
