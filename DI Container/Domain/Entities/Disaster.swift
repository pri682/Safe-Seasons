//
//  Disaster.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//

import Foundation

struct Disaster: Identifiable, Equatable {
    let id: UUID
    let name: String
    let icon: String
    let severity: DisasterSeverity
    let description: String
    let preparednessSteps: [String]
    let supplies: [String]
    
    init(id: UUID = UUID(), name: String, icon: String, severity: DisasterSeverity, description: String, preparednessSteps: [String], supplies: [String]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.severity = severity
        self.description = description
        self.preparednessSteps = preparednessSteps
        self.supplies = supplies
    }
}

enum DisasterSeverity: String, Equatable {
    case extreme = "Extreme"
    case high = "High"
    case moderate = "Moderate"
    case low = "Low"
}
