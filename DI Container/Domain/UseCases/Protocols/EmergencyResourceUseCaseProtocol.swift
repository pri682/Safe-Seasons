//
//  EmergencyResourceUseCaseProtocol.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//


import Foundation

protocol EmergencyResourceUseCaseProtocol {
    func getAllResources() -> [EmergencyResource]
    func getResourcesByType(_ type: EmergencyResource.ResourceType) -> [EmergencyResource]
}