//
//  DependencyContainer.swift
//  DisasterReady
//
//  Composition root (DIP). Creates concretions; all other layers depend on protocols.
//

import Foundation
import SwiftUI

@MainActor
final class DependencyContainer {
    // Infrastructure
    private let keyValueStore: KeyValueStoring
    private let imageStore: ImageStoring

    // Repositories
    let stateRiskRepository: StateRiskRepositoryProtocol
    let disasterRepository: DisasterRepositoryProtocol
    let checklistRepository: ChecklistRepositoryProtocol
    let weaRepository: WEARepositoryProtocol
    let emergencyResourceRepository: EmergencyResourceRepositoryProtocol
    let weatherAlertRepository: WeatherAlertRepositoryProtocol

    // Use cases
    let stateRiskUseCase: StateRiskUseCaseProtocol
    let disasterUseCase: DisasterUseCaseProtocol
    let checklistUseCase: ChecklistUseCaseProtocol
    let weaUseCase: WEAUseCaseProtocol
    let emergencyResourceUseCase: EmergencyResourceUseCaseProtocol
    let offlineAIUseCase: OfflineAIUseCaseProtocol
    let askUseCase: AskDisasterReadyUseCaseProtocol
    let weatherAlertUseCase: WeatherAlertUseCaseProtocol
    
    // Extended Foundation Models features
    let extendedFeatures: ExtendedFeaturesOrchestrator

    // ViewModels (ISP: views receive only their ViewModel)
    let homeViewModel: HomeViewModel
    let browseViewModel: BrowseViewModel
    let checklistViewModel: ChecklistViewModel
    let mapViewModel: MapViewModel
    let alertsViewModel: AlertsViewModel

    init() {
        keyValueStore = UserDefaultsKeyValueStore()
        imageStore = DocumentDirectoryImageStore()

        stateRiskRepository = StateRiskRepository(store: keyValueStore)
        disasterRepository = DisasterRepository()
        checklistRepository = ChecklistRepository(store: keyValueStore, imageStore: imageStore)
        weaRepository = WEARepository(store: keyValueStore)
        emergencyResourceRepository = EmergencyResourceRepository()
        weatherAlertRepository = WeatherAlertRepository()

        stateRiskUseCase = StateRiskUseCase(repository: stateRiskRepository)
        disasterUseCase = DisasterUseCase(repository: disasterRepository)
        checklistUseCase = ChecklistUseCase(repository: checklistRepository)
        weaUseCase = WEAUseCase(repository: weaRepository)
        emergencyResourceUseCase = EmergencyResourceUseCase(repository: emergencyResourceRepository)
        weatherAlertUseCase = WeatherAlertUseCase(repository: weatherAlertRepository)

        let offlineAIRuleEngine = OfflineAIRuleEngine()
        offlineAIUseCase = OfflineAIUseCase(engine: offlineAIRuleEngine)

        // Start with rule-based fallbacks only so the app launches instantly.
        // FoundationModels classes (with @Generable metadata) can block the main thread
        // during framework initialization on iOS 26 beta, causing a white screen.
        let ruleBasedExtended = RuleBasedExtendedFeatures(disasterUseCase: disasterUseCase, offlineAIUseCase: offlineAIUseCase)
        
        // Create orchestrator with fallbacks only (no FM at init)
        extendedFeatures = ExtendedFeaturesOrchestrator(
            preferredAsk: nil,
            fallbackAsk: ruleBasedExtended,
            preferredGuided: nil,
            fallbackGuided: ruleBasedExtended,
            preferredTagging: nil,
            fallbackTagging: ruleBasedExtended,
            preferredSummarization: nil,
            fallbackSummarization: ruleBasedExtended,
            preferredPrioritization: nil,
            fallbackPrioritization: ruleBasedExtended,
            preferredParsing: nil,
            fallbackParsing: ruleBasedExtended,
            preferredConversation: nil,
            fallbackConversation: ruleBasedExtended
        )
        
        // Legacy ask use case (rule-based only at init)
        let ruleBasedAsk = RuleBasedAskUseCase(disasterUseCase: disasterUseCase, offlineAIUseCase: offlineAIUseCase)
        askUseCase = AskDisasterReadyOrchestrator(preferred: nil, fallback: ruleBasedAsk)

        homeViewModel = HomeViewModel(
            stateUseCase: stateRiskUseCase,
            offlineAIUseCase: offlineAIUseCase,
            askUseCase: askUseCase,
            weatherAlertUseCase: weatherAlertUseCase,
            extendedFeatures: extendedFeatures
        )
        browseViewModel = BrowseViewModel(disasterUseCase: disasterUseCase)
        checklistViewModel = ChecklistViewModel(checklistUseCase: checklistUseCase)
        mapViewModel = MapViewModel(resourceUseCase: emergencyResourceUseCase)
        alertsViewModel = AlertsViewModel(weaUseCase: weaUseCase, weatherAlertUseCase: weatherAlertUseCase, stateRiskUseCase: stateRiskUseCase)
    }
    
    /// Call after the first frame renders to lazily initialize Foundation Models on a background thread.
    /// This avoids blocking app launch while the FoundationModels framework loads its @Generable metadata.
    func initializeFoundationModelsIfAvailable() {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            Task.detached(priority: .userInitiated) {
                // Create FM objects off the main thread so framework init doesn't block the UI.
                let fmExtended = FoundationModelsExtendedFeatures()
                let fmAsk = FoundationModelsAskUseCase()
                
                await MainActor.run {
                    self.extendedFeatures.upgradeToFoundationModels(
                        askUseCase: fmExtended,
                        guidedGeneration: fmExtended,
                        contentTagging: fmExtended,
                        summarization: fmExtended,
                        emergencyPrioritization: fmExtended,
                        queryParsing: fmExtended,
                        conversationSession: fmExtended
                    )
                    // Upgrade the legacy ask orchestrator too
                    if let orchestrator = self.askUseCase as? AskDisasterReadyOrchestrator {
                        orchestrator.upgradePreferred(fmAsk)
                    }
                }
            }
        }
        #endif
    }
}

