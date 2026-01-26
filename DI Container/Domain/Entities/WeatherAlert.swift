//
//  WeatherAlert.swift
//  SafeSeasons
//
//  SRP: NWS-style weather alert entity. Offline only (preloaded templates).
//

import Foundation

struct WeatherAlert: Identifiable, Equatable {
    let id: UUID
    let type: AlertType
    let severity: AlertSeverity
    let area: String // e.g. "Texas", "Central Texas"
    let title: String // e.g. "Extreme Cold Warning"
    let description: String
    let effectiveDate: Date?
    let expiresDate: Date?
    let source: String // e.g. "National Weather Service"
    let issuedDate: Date?

    init(
        id: UUID = UUID(),
        type: AlertType,
        severity: AlertSeverity,
        area: String,
        title: String,
        description: String,
        effectiveDate: Date? = nil,
        expiresDate: Date? = nil,
        source: String = "National Weather Service",
        issuedDate: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.severity = severity
        self.area = area
        self.title = title
        self.description = description
        self.effectiveDate = effectiveDate
        self.expiresDate = expiresDate
        self.source = source
        self.issuedDate = issuedDate
    }
}

enum AlertType: String, Equatable, CaseIterable {
    case extremeCold = "Extreme Cold Warning"
    case winterStorm = "Winter Storm Warning"
    case blizzard = "Blizzard Warning"
    case tornado = "Tornado Warning"
    case severeThunderstorm = "Severe Thunderstorm Warning"
    case flashFlood = "Flash Flood Warning"
    case flood = "Flood Warning"
    case hurricane = "Hurricane Warning"
    case heat = "Heat Warning"
    case extremeHeat = "Extreme Heat Warning"
    case wildfire = "Wildfire Warning"
    case dustStorm = "Dust Storm Warning"
    case airQuality = "Air Quality Alert"
}

enum AlertSeverity: String, Equatable {
    case extreme = "Extreme"
    case severe = "Severe"
    case moderate = "Moderate"
    case minor = "Minor"
    case unknown = "Unknown"
}
