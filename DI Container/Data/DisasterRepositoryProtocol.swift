//
//  DisasterRepositoryProtocol.swift
//  SafeSeasons
//

import Foundation

protocol DisasterRepositoryProtocol {
    func fetchCategories() -> [DisasterCategory]
    func fetchDisasterById(_ id: UUID) -> Disaster?
}
