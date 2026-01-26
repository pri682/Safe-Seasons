//
//  ChecklistItem.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//


import Foundation

struct ChecklistItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let category: ChecklistCategory
    var isCompleted: Bool
    let priority: Priority
    var hasPhoto: Bool
    
    init(id: UUID = UUID(), name: String, category: ChecklistCategory, isCompleted: Bool = false, priority: Priority, hasPhoto: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.isCompleted = isCompleted
        self.priority = priority
        self.hasPhoto = hasPhoto
    }
    
    enum ChecklistCategory: String {
        case basicSupplies = "Basic Supplies"
        case medical = "Medical"
        case documents = "Documents"
        case communication = "Communication"
    }
    
    enum Priority: String {
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
    }
}