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
    let additionalInfo: String
    let warningSigns: [String]
    let duringEvent: [String]
    let sources: [DisasterSource]
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        severity: DisasterSeverity,
        description: String,
        preparednessSteps: [String],
        supplies: [String],
        additionalInfo: String = "",
        warningSigns: [String] = [],
        duringEvent: [String] = [],
        sources: [DisasterSource] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.severity = severity
        self.description = description
        self.preparednessSteps = preparednessSteps
        self.supplies = supplies
        self.additionalInfo = additionalInfo
        self.warningSigns = warningSigns
        self.duringEvent = duringEvent
        self.sources = sources
    }
}

struct DisasterSource: Identifiable, Equatable {
    let id: UUID
    let name: String
    let url: String
    
    init(id: UUID = UUID(), name: String, url: String) {
        self.id = id
        self.name = name
        self.url = url
    }
}

enum DisasterSeverity: String, Equatable {
    case extreme = "Extreme"
    case high = "High"
    case moderate = "Moderate"
    case low = "Low"
}
