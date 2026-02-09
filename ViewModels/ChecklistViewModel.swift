//
//  ChecklistViewModel.swift
//  SafeSeasons
//
//  SRP: Checklist tab presentation. DIP: depends on ChecklistUseCaseProtocol only.
//

import Foundation
import SwiftUI
import UIKit

final class ChecklistViewModel: ObservableObject {
    @Published private(set) var items: [ChecklistItem] = []
    @Published private(set) var completionPercentage: Double = 0

    @Published var selectedCategory: ChecklistItem.ChecklistCategory?

    private let checklistUseCase: ChecklistUseCaseProtocol

    init(checklistUseCase: ChecklistUseCaseProtocol) {
        self.checklistUseCase = checklistUseCase
    }

    func load() {
        items = checklistUseCase.getAllItems()
        completionPercentage = checklistUseCase.getCompletionPercentage()
    }

    func toggleCompletion(_ id: UUID) {
        checklistUseCase.toggleItemCompletion(id)
        load()
    }

    /// Items to display: all or filtered by selected category, sorted by priority then name.
    var displayedItems: [ChecklistItem] {
        let list = selectedCategory == nil ? items : items.filter { $0.category == selectedCategory }
        return list.sorted { lhs, rhs in
            if lhs.priority.rawValue != rhs.priority.rawValue {
                return lhs.priority.sortOrder < rhs.priority.sortOrder
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    /// Items grouped by category for sectioned list (category order: Basic Supplies, Medical, Documents, Communication).
    var itemsGroupedByCategory: [(ChecklistItem.ChecklistCategory, [ChecklistItem])] {
        let order: [ChecklistItem.ChecklistCategory] = [.basicSupplies, .medical, .documents, .communication]
        let grouped = Dictionary(grouping: displayedItems, by: { $0.category })
        return order.compactMap { cat in
            guard let list = grouped[cat], !list.isEmpty else { return nil }
            let sorted = list.sorted { lhs, rhs in
                if lhs.priority.rawValue != rhs.priority.rawValue {
                    return lhs.priority.sortOrder < rhs.priority.sortOrder
                }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return (cat, sorted)
        }
    }

    /// Progress subtitle based on completion (e.g. "Halfway there!", "You're prepared!").
    var progressSubtitle: String {
        switch completionPercentage {
        case 1: return "You're prepared!"
        case 0.75..<1: return "Almost there!"
        case 0.5..<0.75: return "Halfway there!"
        case 0.25..<0.5: return "You're getting there"
        default: return "Keep building your kit"
        }
    }

    func addPhoto(_ image: UIImage, forItemId id: UUID) {
        checklistUseCase.addPhotoToItem(id, image: image)
        load()
    }

    func photoURL(forItemId id: UUID) -> URL? {
        checklistUseCase.photoURL(forItemId: id)
    }
}
