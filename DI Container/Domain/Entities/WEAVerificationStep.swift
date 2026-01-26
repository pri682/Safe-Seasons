//
//  WEAVerificationStep.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//


import Foundation

struct WEAVerificationStep: Identifiable, Equatable {
    let id: UUID
    let title: String
    let instructions: String
    var isComplete: Bool
    
    init(id: UUID = UUID(), title: String, instructions: String, isComplete: Bool = false) {
        self.id = id
        self.title = title
        self.instructions = instructions
        self.isComplete = isComplete
    }
}