//
//  PersistenceKeys.swift
//  SafeSeasons
//
//  Single place for persistence keys. SRP: avoid scattering keys across repos.
//

import Foundation

enum PersistenceKeys {
    static let selectedStateName = "selectedStateName"
    static let checklistCompleted = "checklistCompleted"
    static let checklistPhotos = "checklistPhotos"
    static let checklistPhotoPrefix = "checklistPhoto_"
    static let weaStepsCompleted = "weaStepsCompleted"
}
