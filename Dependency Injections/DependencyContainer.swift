//
//  DependencyContainer.swift
//  SafeSeasons
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
    let askUseCase: AskSafeSeasonsUseCaseProtocol
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

        // Extended features setup
        let ruleBasedExtended = RuleBasedExtendedFeatures(disasterUseCase: disasterUseCase, offlineAIUseCase: offlineAIUseCase)
        
        var fmExtended: ExtendedAskSafeSeasonsUseCaseProtocol? = nil
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            fmExtended = FoundationModelsExtendedFeatures(offlineAIUseCase: offlineAIUseCase)
        }
        #endif
        
        // Create orchestrator for extended features
        extendedFeatures = ExtendedFeaturesOrchestrator(
            preferredAsk: fmExtended,
            fallbackAsk: ruleBasedExtended,
            preferredGuided: fmExtended as? GuidedGenerationUseCaseProtocol,
            fallbackGuided: ruleBasedExtended,
            preferredTagging: fmExtended as? ContentTaggingUseCaseProtocol,
            fallbackTagging: ruleBasedExtended,
            preferredSummarization: fmExtended as? SummarizationUseCaseProtocol,
            fallbackSummarization: ruleBasedExtended,
            preferredPrioritization: fmExtended as? EmergencyPrioritizationUseCaseProtocol,
            fallbackPrioritization: ruleBasedExtended,
            preferredParsing: fmExtended as? QueryParsingUseCaseProtocol,
            fallbackParsing: ruleBasedExtended,
            preferredConversation: fmExtended as? ConversationSessionProtocol,
            fallbackConversation: ruleBasedExtended
        )
        
        // Legacy ask use case (for backward compatibility)
        let ruleBasedAsk = RuleBasedAskUseCase(disasterUseCase: disasterUseCase, offlineAIUseCase: offlineAIUseCase)
        var fmAsk: AskSafeSeasonsUseCaseProtocol? = nil
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            fmAsk = FoundationModelsAskUseCase(offlineAIUseCase: offlineAIUseCase)
        }
        #endif
        askUseCase = AskSafeSeasonsOrchestrator(preferred: fmAsk, fallback: ruleBasedAsk)

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
}

