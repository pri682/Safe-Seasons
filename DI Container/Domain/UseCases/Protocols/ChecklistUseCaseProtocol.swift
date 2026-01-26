//
//  ChecklistUseCaseProtocol.swift
//  SafeSeasons
//

import Foundation
import UIKit

protocol ChecklistUseCaseProtocol {
    func getAllItems() -> [ChecklistItem]
    func toggleItemCompletion(_ id: UUID)
    func getCompletionPercentage() -> Double
    func addPhotoToItem(_ id: UUID, image: UIImage)
    func photoURL(forItemId id: UUID) -> URL?
}