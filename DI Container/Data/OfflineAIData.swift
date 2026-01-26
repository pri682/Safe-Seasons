//
//  OfflineAIData.swift
//  SafeSeasons
//
//  SRP: rules table + narratives store for offline rule-based guidance only.
//  (stateAbbr, month, hazard) → [narrative IDs]; narratives = prewritten strings.
//
//  **Attribution:**
//  - Preparedness tips and safety guidance based on:
//    • Federal Emergency Management Agency (FEMA) - ready.gov
//    • National Weather Service (NWS) - weather.gov/safety
//  - Disaster preparedness recommendations follow official FEMA and NWS public safety resources
//

import Foundation

// MARK: - Narrative IDs

enum RiskNarrativeId: String, CaseIterable, Hashable {
    case flashFloodCommon = "flash_flood_common"
    case avoidUnderpasses = "avoid_underpasses"
    case waterproofDocs = "waterproof_docs"
    case tornadoSeason = "tornado_season"
    case shelterInterior = "shelter_interior"
    case knowWatchVsWarning = "know_watch_vs_warning"
    case hurricanePrep = "hurricane_prep"
    case evacRoutes = "evac_routes"
    case threeDaySupplies = "three_day_supplies"
    case wildfireSeason = "wildfire_season"
    case defensibleSpace = "defensible_space"
    case goBagReady = "go_bag_ready"
    case heatHydrate = "heat_hydrate"
    case stayIndoorsCool = "stay_indoors_cool"
    case checkVulnerable = "check_vulnerable"
    case winterPrep = "winter_prep"
    case earthquakeAnyTime = "earthquake_any_time"
    case dropCoverHold = "drop_cover_hold"
    case gasShutOff = "gas_shut_off"
}

// MARK: - Narratives Store

enum RiskNarratives {
    static func text(for id: RiskNarrativeId) -> String {
        switch id {
        case .flashFloodCommon: return "Flash flooding is common this month."
        case .avoidUnderpasses: return "Avoid underpasses and low-water crossings."
        case .waterproofDocs: return "Emergency kit should include waterproof documents."
        case .tornadoSeason: return "Tornado season is active; stay weather-aware."
        case .shelterInterior: return "Identify a safe room (basement or interior, no windows)."
        case .knowWatchVsWarning: return "Know the difference between watch and warning."
        case .hurricanePrep: return "Hurricane season—know evacuation routes and have supplies."
        case .evacRoutes: return "Know your evacuation routes and meetup points."
        case .threeDaySupplies: return "Stock 3+ days of water, food, and essentials."
        case .wildfireSeason: return "Wildfire risk is elevated; create defensible space."
        case .defensibleSpace: return "Clear 30 feet around structures; remove debris from gutters."
        case .goBagReady: return "Have a go-bag ready with meds, documents, and supplies."
        case .heatHydrate: return "Extreme heat—stay hydrated and limit outdoor activity."
        case .stayIndoorsCool: return "Stay indoors during peak heat; use AC or cooling centers."
        case .checkVulnerable: return "Check on neighbors, especially older or vulnerable people."
        case .winterPrep: return "Winter storms possible—prepare vehicle and home."
        case .earthquakeAnyTime: return "Earthquakes can happen anytime; prepare now."
        case .dropCoverHold: return "Drop, Cover, Hold On—practice your drill."
        case .gasShutOff: return "Know where and how to shut off gas if needed."
        }
    }
}

// MARK: - Rules Table

/// (stateAbbr, month, hazard) → [narrative IDs]. Engine matches and returns tips.
struct OfflineAIRuleEntry {
    let stateAbbr: String
    let month: String
    let hazard: String
    let narrativeIds: [RiskNarrativeId]
}

enum OfflineAIRules {
    static let table: [OfflineAIRuleEntry] = [
        // Texas — Tornado season (Mar–May)
        .init(stateAbbr: "TX", month: "March", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior, .knowWatchVsWarning]),
        .init(stateAbbr: "TX", month: "April", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior, .knowWatchVsWarning]),
        .init(stateAbbr: "TX", month: "May", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior, .knowWatchVsWarning]),
        .init(stateAbbr: "TX", month: "March", hazard: "Severe Storms", narrativeIds: [.tornadoSeason, .avoidUnderpasses]),
        .init(stateAbbr: "TX", month: "April", hazard: "Severe Storms", narrativeIds: [.tornadoSeason, .avoidUnderpasses]),
        .init(stateAbbr: "TX", month: "May", hazard: "Severe Storms", narrativeIds: [.tornadoSeason, .avoidUnderpasses]),
        // Texas — Flooding (spring)
        .init(stateAbbr: "TX", month: "April", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "TX", month: "May", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        // Texas — Hurricane (Jun–Oct)
        .init(stateAbbr: "TX", month: "June", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "July", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "August", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "September", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "October", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "June", hazard: "Tropical Storms", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "July", hazard: "Tropical Storms", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "August", hazard: "Tropical Storms", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "September", hazard: "Tropical Storms", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "October", hazard: "Tropical Storms", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        // Texas — Summer heat
        .init(stateAbbr: "TX", month: "June", hazard: "Extreme Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool, .checkVulnerable]),
        .init(stateAbbr: "TX", month: "July", hazard: "Extreme Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool, .checkVulnerable]),
        .init(stateAbbr: "TX", month: "August", hazard: "Extreme Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool, .checkVulnerable]),
        .init(stateAbbr: "TX", month: "June", hazard: "Drought", narrativeIds: [.heatHydrate, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "July", hazard: "Drought", narrativeIds: [.heatHydrate, .threeDaySupplies]),
        .init(stateAbbr: "TX", month: "August", hazard: "Drought", narrativeIds: [.heatHydrate, .threeDaySupplies]),
        // Oklahoma — Tornado
        .init(stateAbbr: "OK", month: "April", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior, .knowWatchVsWarning]),
        .init(stateAbbr: "OK", month: "May", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior, .knowWatchVsWarning]),
        .init(stateAbbr: "OK", month: "June", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior]),
        .init(stateAbbr: "OK", month: "April", hazard: "Hail", narrativeIds: [.tornadoSeason, .shelterInterior]),
        .init(stateAbbr: "OK", month: "May", hazard: "Hail", narrativeIds: [.tornadoSeason, .shelterInterior]),
        .init(stateAbbr: "OK", month: "June", hazard: "Hail", narrativeIds: [.tornadoSeason, .shelterInterior]),
        // Oklahoma — Winter
        .init(stateAbbr: "OK", month: "December", hazard: "Ice Storms", narrativeIds: [.winterPrep, .threeDaySupplies]),
        .init(stateAbbr: "OK", month: "January", hazard: "Ice Storms", narrativeIds: [.winterPrep, .threeDaySupplies]),
        .init(stateAbbr: "OK", month: "February", hazard: "Ice Storms", narrativeIds: [.winterPrep, .threeDaySupplies]),
        .init(stateAbbr: "OK", month: "December", hazard: "Blizzards", narrativeIds: [.winterPrep, .threeDaySupplies]),
        .init(stateAbbr: "OK", month: "January", hazard: "Blizzards", narrativeIds: [.winterPrep, .threeDaySupplies]),
        .init(stateAbbr: "OK", month: "February", hazard: "Blizzards", narrativeIds: [.winterPrep, .threeDaySupplies]),
        // California — Wildfire
        .init(stateAbbr: "CA", month: "June", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "CA", month: "July", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "CA", month: "August", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "CA", month: "September", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "CA", month: "October", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "CA", month: "June", hazard: "Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool]),
        .init(stateAbbr: "CA", month: "July", hazard: "Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool]),
        .init(stateAbbr: "CA", month: "August", hazard: "Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool]),
        .init(stateAbbr: "CA", month: "September", hazard: "Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool]),
        .init(stateAbbr: "CA", month: "October", hazard: "Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool]),
        // California — Winter mudslides/floods
        .init(stateAbbr: "CA", month: "November", hazard: "Mudslides", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .goBagReady]),
        .init(stateAbbr: "CA", month: "December", hazard: "Mudslides", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .goBagReady]),
        .init(stateAbbr: "CA", month: "January", hazard: "Mudslides", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .goBagReady]),
        .init(stateAbbr: "CA", month: "February", hazard: "Mudslides", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .goBagReady]),
        .init(stateAbbr: "CA", month: "November", hazard: "Floods", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "CA", month: "December", hazard: "Floods", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "CA", month: "January", hazard: "Floods", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "CA", month: "February", hazard: "Floods", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        // California — Earthquake (All Year)
        .init(stateAbbr: "CA", month: "All Year", hazard: "Earthquakes", narrativeIds: [.earthquakeAnyTime, .dropCoverHold, .gasShutOff]),
        // Florida — Hurricane
        .init(stateAbbr: "FL", month: "June", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "FL", month: "July", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "FL", month: "August", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "FL", month: "September", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "FL", month: "October", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "FL", month: "November", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "FL", month: "June", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        .init(stateAbbr: "FL", month: "July", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        .init(stateAbbr: "FL", month: "August", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        .init(stateAbbr: "FL", month: "September", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        .init(stateAbbr: "FL", month: "October", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        .init(stateAbbr: "FL", month: "November", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        // Florida — Summer thunderstorms / flooding
        .init(stateAbbr: "FL", month: "May", hazard: "Thunderstorms", narrativeIds: [.avoidUnderpasses, .knowWatchVsWarning]),
        .init(stateAbbr: "FL", month: "June", hazard: "Thunderstorms", narrativeIds: [.avoidUnderpasses, .knowWatchVsWarning]),
        .init(stateAbbr: "FL", month: "July", hazard: "Thunderstorms", narrativeIds: [.avoidUnderpasses, .knowWatchVsWarning]),
        .init(stateAbbr: "FL", month: "August", hazard: "Thunderstorms", narrativeIds: [.avoidUnderpasses, .knowWatchVsWarning]),
        .init(stateAbbr: "FL", month: "May", hazard: "Lightning", narrativeIds: [.knowWatchVsWarning, .shelterInterior]),
        .init(stateAbbr: "FL", month: "June", hazard: "Lightning", narrativeIds: [.knowWatchVsWarning, .shelterInterior]),
        .init(stateAbbr: "FL", month: "July", hazard: "Lightning", narrativeIds: [.knowWatchVsWarning, .shelterInterior]),
        .init(stateAbbr: "FL", month: "August", hazard: "Lightning", narrativeIds: [.knowWatchVsWarning, .shelterInterior]),
        .init(stateAbbr: "FL", month: "May", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "FL", month: "June", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "FL", month: "July", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "FL", month: "August", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        // Louisiana — Hurricane
        .init(stateAbbr: "LA", month: "June", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "LA", month: "July", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "LA", month: "August", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "LA", month: "September", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "LA", month: "October", hazard: "Hurricanes", narrativeIds: [.hurricanePrep, .evacRoutes, .threeDaySupplies]),
        .init(stateAbbr: "LA", month: "June", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        .init(stateAbbr: "LA", month: "July", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        .init(stateAbbr: "LA", month: "August", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        .init(stateAbbr: "LA", month: "September", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        .init(stateAbbr: "LA", month: "October", hazard: "Storm Surge", narrativeIds: [.hurricanePrep, .evacRoutes, .waterproofDocs]),
        .init(stateAbbr: "LA", month: "April", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "LA", month: "May", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "LA", month: "June", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "LA", month: "September", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "LA", month: "October", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "LA", month: "April", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior, .knowWatchVsWarning]),
        .init(stateAbbr: "LA", month: "May", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior, .knowWatchVsWarning]),
        .init(stateAbbr: "LA", month: "June", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior]),
        .init(stateAbbr: "LA", month: "September", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior]),
        .init(stateAbbr: "LA", month: "October", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior]),
        // Kansas — Tornado / severe
        .init(stateAbbr: "KS", month: "April", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior, .knowWatchVsWarning]),
        .init(stateAbbr: "KS", month: "May", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior, .knowWatchVsWarning]),
        .init(stateAbbr: "KS", month: "June", hazard: "Tornadoes", narrativeIds: [.tornadoSeason, .shelterInterior]),
        .init(stateAbbr: "KS", month: "April", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "KS", month: "May", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "KS", month: "June", hazard: "Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        // Colorado — Wildfire / winter
        .init(stateAbbr: "CO", month: "June", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "CO", month: "July", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "CO", month: "August", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "CO", month: "November", hazard: "Blizzards", narrativeIds: [.winterPrep, .threeDaySupplies]),
        .init(stateAbbr: "CO", month: "December", hazard: "Blizzards", narrativeIds: [.winterPrep, .threeDaySupplies]),
        .init(stateAbbr: "CO", month: "January", hazard: "Blizzards", narrativeIds: [.winterPrep, .threeDaySupplies]),
        .init(stateAbbr: "CO", month: "February", hazard: "Blizzards", narrativeIds: [.winterPrep, .threeDaySupplies]),
        .init(stateAbbr: "CO", month: "March", hazard: "Blizzards", narrativeIds: [.winterPrep, .threeDaySupplies]),
        .init(stateAbbr: "CO", month: "November", hazard: "Avalanches", narrativeIds: [.winterPrep, .evacRoutes]),
        .init(stateAbbr: "CO", month: "December", hazard: "Avalanches", narrativeIds: [.winterPrep, .evacRoutes]),
        .init(stateAbbr: "CO", month: "January", hazard: "Avalanches", narrativeIds: [.winterPrep, .evacRoutes]),
        .init(stateAbbr: "CO", month: "February", hazard: "Avalanches", narrativeIds: [.winterPrep, .evacRoutes]),
        .init(stateAbbr: "CO", month: "March", hazard: "Avalanches", narrativeIds: [.winterPrep, .evacRoutes]),
        // Arizona — Monsoon / heat
        .init(stateAbbr: "AZ", month: "June", hazard: "Monsoon Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "AZ", month: "July", hazard: "Monsoon Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "AZ", month: "August", hazard: "Monsoon Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "AZ", month: "September", hazard: "Monsoon Flooding", narrativeIds: [.flashFloodCommon, .avoidUnderpasses, .waterproofDocs]),
        .init(stateAbbr: "AZ", month: "May", hazard: "Extreme Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool, .checkVulnerable]),
        .init(stateAbbr: "AZ", month: "June", hazard: "Extreme Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool, .checkVulnerable]),
        .init(stateAbbr: "AZ", month: "July", hazard: "Extreme Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool, .checkVulnerable]),
        .init(stateAbbr: "AZ", month: "August", hazard: "Extreme Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool, .checkVulnerable]),
        .init(stateAbbr: "AZ", month: "September", hazard: "Extreme Heat", narrativeIds: [.heatHydrate, .stayIndoorsCool, .checkVulnerable]),
        .init(stateAbbr: "AZ", month: "June", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "AZ", month: "July", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "AZ", month: "August", hazard: "Wildfires", narrativeIds: [.wildfireSeason, .defensibleSpace, .goBagReady]),
        .init(stateAbbr: "AZ", month: "May", hazard: "Drought", narrativeIds: [.heatHydrate, .threeDaySupplies]),
        .init(stateAbbr: "AZ", month: "June", hazard: "Drought", narrativeIds: [.heatHydrate, .threeDaySupplies]),
        .init(stateAbbr: "AZ", month: "July", hazard: "Drought", narrativeIds: [.heatHydrate, .threeDaySupplies]),
        .init(stateAbbr: "AZ", month: "August", hazard: "Drought", narrativeIds: [.heatHydrate, .threeDaySupplies]),
    ]
}
