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

    func addPhoto(_ image: UIImage, forItemId id: UUID) {
        checklistUseCase.addPhotoToItem(id, image: image)
        load()
    }

    func photoURL(forItemId id: UUID) -> URL? {
        checklistUseCase.photoURL(forItemId: id)
    }
}
