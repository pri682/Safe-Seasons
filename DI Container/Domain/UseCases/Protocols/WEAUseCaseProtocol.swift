//
//  WEAUseCaseProtocol.swift
//  SafeSeasons
//
//  Created by Priyanka Karki on 1/24/26.
//


import Foundation

protocol WEAUseCaseProtocol {
    func getVerificationSteps() -> [WEAVerificationStep]
    func toggleStepCompletion(_ id: UUID)
    func isWEAVerified() -> Bool
    func getEducation() -> WEAEducationContent
    func getSeasonalReminders() -> [SeasonalReminder]
}