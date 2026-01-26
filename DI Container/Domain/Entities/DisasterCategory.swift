//
//  DisasterCategory.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//

import Foundation

struct DisasterCategory: Identifiable, Equatable {
    let id: UUID
    let name: String
    let icon: String
    let color: String
    let disasters: [Disaster]
    
    init(id: UUID = UUID(), name: String, icon: String, color: String, disasters: [Disaster]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.disasters = disasters
    }
}
