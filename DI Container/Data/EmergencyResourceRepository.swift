//
//  EmergencyResourceRepository.swift
//  SafeSeasons
//
//  SRP: emergency resource data access only. Read-only from EmbeddedData.
//

import Foundation

final class EmergencyResourceRepository: EmergencyResourceRepositoryProtocol {
    func fetchAll() -> [EmergencyResource] {
        EmbeddedData.emergencyResources
    }

    func fetch(byType type: EmergencyResource.ResourceType) -> [EmergencyResource] {
        EmbeddedData.emergencyResources.filter { $0.type == type }
    }
}
