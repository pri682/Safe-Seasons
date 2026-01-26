//
//  ChecklistRepositoryProtocol.swift
//  SafeSeasons
//
//  DIP: use cases depend on this, not concrete ChecklistRepository.
//

import Foundation
import UIKit

protocol ChecklistRepositoryProtocol: AnyObject {
    func fetchItems() -> [ChecklistItem]
    func toggleCompletion(_ id: UUID)
    func completionPercentage() -> Double
    func savePhoto(_ image: UIImage, forItemId id: UUID)
    func photoURL(forItemId id: UUID) -> URL?
}
