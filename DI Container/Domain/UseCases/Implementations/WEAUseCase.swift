//
//  WEAUseCase.swift
//  SafeSeasons
//
//  SRP: WEA verification & education orchestration. DIP: depends on WEARepositoryProtocol only.
//

import Foundation

final class WEAUseCase: WEAUseCaseProtocol {
    private let repository: WEARepositoryProtocol

    init(repository: WEARepositoryProtocol) {
        self.repository = repository
    }

    func getVerificationSteps() -> [WEAVerificationStep] {
        repository.fetchVerificationSteps()
    }

    func toggleStepCompletion(_ id: UUID) {
        repository.toggleStepCompletion(id)
    }

    func isWEAVerified() -> Bool {
        repository.isWEAVerified()
    }

    func getEducation() -> WEAEducationContent {
        repository.fetchEducation()
    }

    func getSeasonalReminders() -> [SeasonalReminder] {
        repository.fetchSeasonalReminders()
    }
}
