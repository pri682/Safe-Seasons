//
//  WEARepository.swift
//  SafeSeasons
//
//  SRP: WEA data access only. DIP: depends on KeyValueStoring.
//

import Foundation

final class WEARepository: WEARepositoryProtocol {
    private let store: KeyValueStoring

    init(store: KeyValueStoring) {
        self.store = store
    }

    func fetchVerificationSteps() -> [WEAVerificationStep] {
        let base = EmbeddedData.weaVerificationSteps
        let completed = (store.object(forKey: PersistenceKeys.weaStepsCompleted) as? [String: Bool]) ?? [:]
        return base.enumerated().map { index, step in
            var copy = step
            copy.isComplete = completed["\(index)"] ?? false
            return copy
        }
    }

    func toggleStepCompletion(_ id: UUID) {
        let base = EmbeddedData.weaVerificationSteps
        guard let index = base.firstIndex(where: { $0.id == id }) else { return }
        var completed = (store.object(forKey: PersistenceKeys.weaStepsCompleted) as? [String: Bool]) ?? [:]
        let key = "\(index)"
        completed[key] = !(completed[key] ?? false)
        store.set(completed, forKey: PersistenceKeys.weaStepsCompleted)
    }

    func isWEAVerified() -> Bool {
        fetchVerificationSteps().allSatisfy(\.isComplete)
    }

    func fetchEducation() -> WEAEducationContent {
        EmbeddedData.weaEducation
    }

    func fetchSeasonalReminders() -> [SeasonalReminder] {
        EmbeddedData.seasonalReminders
    }
}
