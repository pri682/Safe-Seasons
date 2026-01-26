//
//  EmergencyResourceUseCase.swift
//  SafeSeasons
//
//  SRP: emergency resources orchestration. DIP: depends on EmergencyResourceRepositoryProtocol only.
//

import Foundation

final class EmergencyResourceUseCase: EmergencyResourceUseCaseProtocol {
    private let repository: EmergencyResourceRepositoryProtocol

    init(repository: EmergencyResourceRepositoryProtocol) {
        self.repository = repository
    }

    func getAllResources() -> [EmergencyResource] {
        repository.fetchAll()
    }

    func getResourcesByType(_ type: EmergencyResource.ResourceType) -> [EmergencyResource] {
        repository.fetch(byType: type)
    }
}
