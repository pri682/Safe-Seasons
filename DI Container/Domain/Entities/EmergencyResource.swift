//
//  EmergencyResource.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//


import Foundation

struct EmergencyResource: Identifiable, Equatable {
    let id: UUID
    let name: String
    let type: ResourceType
    let coordinate: Coordinate
    let address: String
    
    init(id: UUID = UUID(), name: String, type: ResourceType, coordinate: Coordinate, address: String) {
        self.id = id
        self.name = name
        self.type = type
        self.coordinate = coordinate
        self.address = address
    }
    
    enum ResourceType: String {
        case hospital = "Hospital"
        case shelter = "Shelter"
        case fireStation = "Fire Station"
        case policeStation = "Police Station"
    }
}

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double
}