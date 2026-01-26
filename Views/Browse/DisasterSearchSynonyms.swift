//
//  DisasterSearchSynonyms.swift
//  SafeSeasons
//
//  Synonym / related-term map for Browse search. On-device, no network.
//

import Foundation

enum DisasterSearchSynonyms {
    /// Lowercased search term -> disaster names that should match.
    private static let map: [String: Set<String>] = [
        "quake": ["Earthquakes"],
        "earthquake": ["Earthquakes"],
        "seismic": ["Earthquakes"],
        "storm": ["Hurricanes", "Severe Thunderstorms", "Dust Storms"],
        "storms": ["Hurricanes", "Severe Thunderstorms", "Dust Storms"],
        "hurricane": ["Hurricanes"],
        "cyclone": ["Hurricanes"],
        "flood": ["Flooding"],
        "flooding": ["Flooding"],
        "floods": ["Flooding"],
        "thunder": ["Severe Thunderstorms"],
        "lightning": ["Severe Thunderstorms"],
        "hail": ["Hail"],
        "dust": ["Dust Storms"],
        "wildfire": ["Wildfires"],
        "wildfires": ["Wildfires"],
        "fire": ["Wildfires"],
        "blaze": ["Wildfires"],
        "heat": ["Extreme Heat"],
        "drought": ["Drought"],
        "dry": ["Drought"],
        "blizzard": ["Blizzards"],
        "blizzards": ["Blizzards"],
        "snow": ["Blizzards"],
        "ice": ["Ice Storms"],
        "avalanche": ["Avalanches"],
        "avalanches": ["Avalanches"],
        "landslide": ["Landslides"],
        "landslides": ["Landslides"],
        "slide": ["Landslides"],
        "tsunami": ["Tsunamis"],
        "tsunamis": ["Tsunamis"],
        "wave": ["Tsunamis"],
        "waves": ["Tsunamis"],
        "sinkhole": ["Sinkholes"],
        "sinkholes": ["Sinkholes"],
        "tornado": ["Tornadoes"],
        "tornadoes": ["Tornadoes"],
        "twister": ["Tornadoes"],
    ]

    /// Returns disaster names that match the query via synonym map.
    static func disasterNames(for query: String) -> Set<String> {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        var names: Set<String> = []
        if let mapped = map[q] {
            names.formUnion(mapped)
        }
        let tokens = q.split(separator: " ").map(String.init)
        for t in tokens where t.count > 1 {
            if let mapped = map[String(t)] {
                names.formUnion(mapped)
            }
        }
        return names
    }
}
