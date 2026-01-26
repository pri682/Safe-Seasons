//
//  DisasterRepository.swift
//  SafeSeasons
//
//  SRP: disaster/category data access only. DIP: depends on EmbeddedData (data source).
//

import Foundation

final class DisasterRepository: DisasterRepositoryProtocol {
    func fetchCategories() -> [DisasterCategory] {
        EmbeddedData.disasterCategories
    }

    func fetchDisasterById(_ id: UUID) -> Disaster? {
        EmbeddedData.disasterCategories
            .flatMap { $0.disasters }
            .first { $0.id == id }
    }
}
