//
//  MapViewModel.swift
//  SafeSeasons
//
//  SRP: Map tab presentation. Embedded resources only (no network).
//

import Foundation
import SwiftUI

final class MapViewModel: ObservableObject {
    @Published private(set) var resources: [EmergencyResource] = []
    @Published var visibleTypes: Set<EmergencyResource.ResourceType> = []

    private let resourceUseCase: EmergencyResourceUseCaseProtocol

    init(resourceUseCase: EmergencyResourceUseCaseProtocol) {
        self.resourceUseCase = resourceUseCase
    }

    func load() {
        let embedded = resourceUseCase.getAllResources()
        resources = embedded
        if visibleTypes.isEmpty {
            visibleTypes = Set(allTypesFromResources(embedded))
        }
    }

    var allTypes: [EmergencyResource.ResourceType] {
        Array(Set(resources.map { $0.type })).sorted { $0.rawValue < $1.rawValue }
    }

    var filteredResources: [EmergencyResource] {
        resources.filter { visibleTypes.contains($0.type) }
    }

    func toggleType(_ type: EmergencyResource.ResourceType) {
        if visibleTypes.contains(type) {
            visibleTypes.remove(type)
        } else {
            visibleTypes.insert(type)
        }
    }

    private func allTypesFromResources(_ r: [EmergencyResource]) -> [EmergencyResource.ResourceType] {
        Array(Set(r.map { $0.type })).sorted { $0.rawValue < $1.rawValue }
    }
}
