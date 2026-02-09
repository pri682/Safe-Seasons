//
//  EmergencyResourceRepository.swift
//  SafeSeasons
//
//  SRP: emergency resource data access. Loads from JSON first (Data/resources.json), fallback to EmbeddedData.
//  Fully offline; no APIs. Edit resources.json to add/change POIs without recompiling.
//

import Foundation

final class EmergencyResourceRepository: EmergencyResourceRepositoryProtocol {
    private lazy var cachedResources: [EmergencyResource] = loadResources()

    func fetchAll() -> [EmergencyResource] {
        cachedResources
    }

    func fetch(byType type: EmergencyResource.ResourceType) -> [EmergencyResource] {
        cachedResources.filter { $0.type == type }
    }

    /// Load POIs from bundled JSON (Data/resources.json) if present; otherwise use EmbeddedData.
    private func loadResources() -> [EmergencyResource] {
        guard let url = resolveResourcesJSONURL(),
              let data = try? Data(contentsOf: url),
              let records = try? JSONDecoder().decode([EmergencyResourceRecord].self, from: data) else {
            return EmbeddedData.emergencyResources
        }
        let resources = records.compactMap { $0.toResource() }
        return resources.isEmpty ? EmbeddedData.emergencyResources : resources
    }

    /// Resolve URL for resources.json from the app bundle (Data/resources.json or resources.json).
    private func resolveResourcesJSONURL() -> URL? {
        if let url = Bundle.main.url(forResource: "resources", withExtension: "json", subdirectory: "Data") {
            return url
        }
        if let url = Bundle.main.url(forResource: "resources", withExtension: "json") {
            return url
        }
        return nil
    }
}
