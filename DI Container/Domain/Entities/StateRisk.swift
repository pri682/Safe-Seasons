//
//  StateRisk.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//


import Foundation

struct StateRisk: Identifiable, Equatable {
    let id: UUID
    let name: String
    let abbreviation: String
    let riskLevel: RiskLevel
    let topHazards: [String]
    let seasonalRisks: [SeasonalRisk]
    
    init(id: UUID = UUID(), name: String, abbreviation: String, riskLevel: RiskLevel, topHazards: [String], seasonalRisks: [SeasonalRisk]) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.riskLevel = riskLevel
        self.topHazards = topHazards
        self.seasonalRisks = seasonalRisks
    }
}

enum RiskLevel: String, Equatable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case veryHigh = "Very High"
}

struct SeasonalRisk: Equatable {
    let season: String
    let months: [String]
    let hazards: [String]
    let riskLevel: RiskLevel
}