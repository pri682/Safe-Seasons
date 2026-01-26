//
//  DisasterUseCase.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//


import Foundation

final class DisasterUseCase: DisasterUseCaseProtocol {
    private let repository: DisasterRepositoryProtocol
    
    init(repository: DisasterRepositoryProtocol) {
        self.repository = repository
    }
    
    func getAllCategories() -> [DisasterCategory] {
        return repository.fetchCategories()
    }
    
    func searchDisasters(query: String) -> [Disaster] {
        let allDisasters = repository.fetchCategories().flatMap { $0.disasters }
        guard !query.isEmpty else { return allDisasters }
        return allDisasters.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func getDisasterById(_ id: UUID) -> Disaster? {
        return repository.fetchDisasterById(id)
    }
}