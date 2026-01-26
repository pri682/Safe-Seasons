//
//  WEARepositoryProtocol.swift
//  SafeSeasons
//
//  DIP: use cases depend on this, not concrete WEARepository.
//

import Foundation

protocol WEARepositoryProtocol: AnyObject {
    func fetchVerificationSteps() -> [WEAVerificationStep]
    func toggleStepCompletion(_ id: UUID)
    func isWEAVerified() -> Bool
    func fetchEducation() -> WEAEducationContent
    func fetchSeasonalReminders() -> [SeasonalReminder]
}
