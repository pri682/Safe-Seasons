//
//  AlertsViewModel.swift
//  SafeSeasons
//
//  SRP: Alerts tab presentation. DIP: depends on WEAUseCaseProtocol, WeatherAlertUseCaseProtocol, StateRiskUseCaseProtocol.
//

import Foundation
import SwiftUI

final class AlertsViewModel: ObservableObject {
    @Published private(set) var verificationSteps: [WEAVerificationStep] = []
    @Published private(set) var isWEAVerified: Bool = false
    @Published private(set) var education: WEAEducationContent?
    @Published private(set) var seasonalReminders: [SeasonalReminder] = []
    @Published private(set) var weatherAlerts: [WeatherAlert] = []

    private let weaUseCase: WEAUseCaseProtocol
    private let weatherAlertUseCase: WeatherAlertUseCaseProtocol
    private let stateRiskUseCase: StateRiskUseCaseProtocol
    private let currentMonthProvider: () -> String

    init(
        weaUseCase: WEAUseCaseProtocol,
        weatherAlertUseCase: WeatherAlertUseCaseProtocol,
        stateRiskUseCase: StateRiskUseCaseProtocol,
        currentMonthProvider: @escaping () -> String
    ) {
        self.weaUseCase = weaUseCase
        self.weatherAlertUseCase = weatherAlertUseCase
        self.stateRiskUseCase = stateRiskUseCase
        self.currentMonthProvider = currentMonthProvider
    }
    
    convenience init(
        weaUseCase: WEAUseCaseProtocol,
        weatherAlertUseCase: WeatherAlertUseCaseProtocol,
        stateRiskUseCase: StateRiskUseCaseProtocol
    ) {
        self.init(
            weaUseCase: weaUseCase,
            weatherAlertUseCase: weatherAlertUseCase,
            stateRiskUseCase: stateRiskUseCase,
            currentMonthProvider: AlertsViewModel.defaultMonth
        )
    }

    func load() {
        verificationSteps = weaUseCase.getVerificationSteps()
        isWEAVerified = weaUseCase.isWEAVerified()
        education = weaUseCase.getEducation()
        seasonalReminders = weaUseCase.getSeasonalReminders()
        
        let state = stateRiskUseCase.getCurrentState()
        #if DEBUG
        let month = debugMonthOverride ?? currentMonthProvider()
        #else
        let month = currentMonthProvider()
        #endif
        weatherAlerts = weatherAlertUseCase.getAlerts(state: state, month: month)
    }

    func toggleStepCompletion(_ id: UUID) {
        weaUseCase.toggleStepCompletion(id)
        load()
    }

    #if DEBUG
    /// Debug-only: Override month for testing. Set to "January", "May", etc. to test different alerts.
    var debugMonthOverride: String? = nil
    #endif

    private static func defaultMonth() -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f.string(from: Date())
    }
}
