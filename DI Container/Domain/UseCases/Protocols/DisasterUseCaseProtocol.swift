//
//  DisasterUseCaseProtocol.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//


import Foundation

protocol DisasterUseCaseProtocol {
    func getAllCategories() -> [DisasterCategory]
    func searchDisasters(query: String) -> [Disaster]
    func getDisasterById(_ id: UUID) -> Disaster?
}