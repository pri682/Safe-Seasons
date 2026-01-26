//
//  ChecklistRepository.swift
//  SafeSeasons
//
//  SRP: checklist data access only. DIP: depends on KeyValueStoring, ImageStoring.
//

import Foundation
import UIKit

final class ChecklistRepository: ChecklistRepositoryProtocol {
    private let store: KeyValueStoring
    private let imageStore: ImageStoring

    init(store: KeyValueStoring, imageStore: ImageStoring) {
        self.store = store
        self.imageStore = imageStore
    }

    func fetchItems() -> [ChecklistItem] {
        let base = EmbeddedData.checklistItems
        let completed = (store.object(forKey: PersistenceKeys.checklistCompleted) as? [String: Bool]) ?? [:]
        let photoIds = Set((store.object(forKey: PersistenceKeys.checklistPhotos) as? [String]) ?? [])
        return base.map { item in
            var copy = item
            copy.isCompleted = completed[item.id.uuidString] ?? false
            copy.hasPhoto = photoIds.contains(item.id.uuidString)
            return copy
        }
    }

    func toggleCompletion(_ id: UUID) {
        var completed = (store.object(forKey: PersistenceKeys.checklistCompleted) as? [String: Bool]) ?? [:]
        let key = id.uuidString
        let current = completed[key] ?? false
        completed[key] = !current
        store.set(completed, forKey: PersistenceKeys.checklistCompleted)
    }

    func completionPercentage() -> Double {
        let items = fetchItems()
        let total = items.count
        guard total > 0 else { return 0 }
        let done = items.filter(\.isCompleted).count
        return Double(done) / Double(total)
    }

    func savePhoto(_ image: UIImage, forItemId id: UUID) {
        guard imageStore.saveImage(image, forId: id) else { return }
        var ids = (store.object(forKey: PersistenceKeys.checklistPhotos) as? [String]) ?? []
        let key = id.uuidString
        if !ids.contains(key) {
            ids.append(key)
            store.set(ids, forKey: PersistenceKeys.checklistPhotos)
        }
    }

    func photoURL(forItemId id: UUID) -> URL? {
        imageStore.loadImageURL(forId: id)
    }
}
