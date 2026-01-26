//
//  ChecklistUseCase.swift
//  SafeSeasons
//
//  SRP: checklist orchestration. DIP: depends on ChecklistRepositoryProtocol only.
//

import Foundation
import UIKit

final class ChecklistUseCase: ChecklistUseCaseProtocol {
    private let repository: ChecklistRepositoryProtocol

    init(repository: ChecklistRepositoryProtocol) {
        self.repository = repository
    }

    func getAllItems() -> [ChecklistItem] {
        repository.fetchItems()
    }

    func toggleItemCompletion(_ id: UUID) {
        repository.toggleCompletion(id)
    }

    func getCompletionPercentage() -> Double {
        repository.completionPercentage()
    }

    func addPhotoToItem(_ id: UUID, image: UIImage) {
        repository.savePhoto(image, forItemId: id)
    }

    func photoURL(forItemId id: UUID) -> URL? {
        repository.photoURL(forItemId: id)
    }
}
