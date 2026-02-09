//
//  EmergencyResourceRecord.swift
//  SafeSeasons
//
//  Codable DTO for loading POIs from JSON (Data/resources.json). Keeps data out of code.
//

import Foundation

/// JSON record for one emergency POI. Decode from resources.json and map to EmergencyResource.
struct EmergencyResourceRecord: Codable {
    let name: String
    let type: String
    let latitude: Double
    let longitude: Double
    let address: String

    func toResource() -> EmergencyResource? {
        let resourceType: EmergencyResource.ResourceType?
        switch type.lowercased() {
        case "hospital": resourceType = .hospital
        case "firestation", "fire_station": resourceType = .fireStation
        case "policestation", "police_station": resourceType = .policeStation
        case "shelter": resourceType = .shelter
        default: resourceType = nil
        }
        guard let t = resourceType else { return nil }
        return EmergencyResource(
            name: name,
            type: t,
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            address: address
        )
    }
}
