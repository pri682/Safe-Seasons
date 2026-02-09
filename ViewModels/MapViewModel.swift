//
//  MapViewModel.swift
//  SafeSeasons
//
//  SRP: Map tab presentation. Embedded resources only; “Near me” = filter by distance (fully offline).
//

import Foundation
import SwiftUI
import CoreLocation

final class MapViewModel: ObservableObject {
    @Published private(set) var resources: [EmergencyResource] = []
    @Published var visibleTypes: Set<EmergencyResource.ResourceType> = []
    /// When set, we show only embedded POIs within this radius (meters). Nil = show all. Used for “Near me” (offline).
    @Published var nearMeCenter: CLLocationCoordinate2D?
    @Published var nearMeError: String?

    /// Radius in meters for “Near me” filter (~300 miles so embedded POIs across US can still appear).
    private let nearMeRadiusMeters: Double = 500_000

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

    /// Resources to show on the map: embedded only, optionally filtered to those “near” user (offline).
    var displayResources: [EmergencyResource] {
        let visible = resources.filter { visibleTypes.contains($0.type) }
        guard let center = nearMeCenter else { return visible }
        return visible.filter { resource in
            distanceMeters(from: center, to: resource.coordinate) <= nearMeRadiusMeters
        }
    }

    /// Embedded resources sorted by distance from user (nearest first). Nil if no user location.
    func resourcesSortedByDistance(from userCoordinate: CLLocationCoordinate2D) -> [EmergencyResource] {
        resources
            .filter { visibleTypes.contains($0.type) }
            .sorted { a, b in
                distanceMeters(from: userCoordinate, to: a.coordinate) < distanceMeters(from: userCoordinate, to: b.coordinate)
            }
    }

    func toggleType(_ type: EmergencyResource.ResourceType) {
        if visibleTypes.contains(type) {
            visibleTypes.remove(type)
        } else {
            visibleTypes.insert(type)
        }
    }

    /// Focus on “near me”: filter map to embedded POIs within radius of user (offline, no API).
    func focusNearMe(center: CLLocationCoordinate2D) {
        nearMeError = nil
        nearMeCenter = center
        let visible = resources.filter { visibleTypes.contains($0.type) }
        let nearby = visible.filter { distanceMeters(from: center, to: $0.coordinate) <= nearMeRadiusMeters }
        if nearby.isEmpty {
            nearMeError = "No embedded emergency locations within range. Showing all locations."
            nearMeCenter = nil
        }
    }

    /// Clear “Near me” filter and show all embedded POIs again.
    func clearNearMeFilter() {
        nearMeCenter = nil
        nearMeError = nil
    }

    /// Approximate distance in meters between two coordinates (Haversine).
    private func distanceMeters(from: CLLocationCoordinate2D, to: Coordinate) -> Double {
        let fromLat = from.latitude * .pi / 180
        let fromLon = from.longitude * .pi / 180
        let toLat = to.latitude * .pi / 180
        let toLon = to.longitude * .pi / 180
        let dLat = toLat - fromLat
        let dLon = toLon - fromLon
        let a = sin(dLat/2)*sin(dLat/2) + cos(fromLat)*cos(toLat)*sin(dLon/2)*sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return 6_371_000 * c // Earth radius in meters
    }

    private func allTypesFromResources(_ r: [EmergencyResource]) -> [EmergencyResource.ResourceType] {
        Array(Set(r.map { $0.type })).sorted { $0.rawValue < $1.rawValue }
    }
}
