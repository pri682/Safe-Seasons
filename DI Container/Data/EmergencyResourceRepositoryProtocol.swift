//
//  EmergencyResourceRepositoryProtocol.swift
//  SafeSeasons
//
//  DIP: use cases depend on this, not concrete EmergencyResourceRepository.
//

import Foundation

protocol EmergencyResourceRepositoryProtocol: AnyObject {
    func fetchAll() -> [EmergencyResource]
    func fetch(byType type: EmergencyResource.ResourceType) -> [EmergencyResource]
}
